import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../services/api/deprecating/trash/trash_api_client.dart';
import '../../services/local/cache_database/cache_database.dart';
import '../../services/local/file_system_service/file_system_service.dart';
import 'trash_repository.dart';

class TrashRepositoryImpl extends TrashRepository {
  TrashRepositoryImpl({
    required this.trashApiClient,
    required this.localDatabase,
    required this.fileSystemService,
  });

  final TrashApiClient trashApiClient;
  final CacheDatabase localDatabase;
  final FileSystemService fileSystemService;
  final _TrashCacheStore _cacheStore = _TrashCacheStore();

  final Logger _log = Logger("TrashRepositoryImpl");

  @override
  Future<Result<void, Exception>> destroyTrashDocument(String id) {
    return _wrapThrow(() async {
      final apiResult = await trashApiClient.destroyTrashDocument(id);
      if (apiResult.isError()) {
        _log.severe("API error when deleting document with id $id");
        return Result.error(Exception("Failed to delete document with id $id"));
      }

      // Remove from local database
      final dbResult = await localDatabase.removeDocument(id);
      if (dbResult.isError()) {
        _log.warning(
          "Failed to remove document from local database",
          dbResult.tryGetError()!,
        );
      }

      // Remove from file system
      final fileResult = await fileSystemService.deleteDocument(id);
      if (fileResult.isError()) {
        _log.warning(
          "Failed to delete document file from file system",
          fileResult.tryGetError()!,
        );
      }

      // Remove from cache
      _cacheStore.removeDocument(id);
      notifyListeners();

      return const Success(null);
    });
  }

  @override
  Future<Result<Document, Exception>> getTrashDocument(String id) {
    return _wrapThrow(() async {
      final cachedDoc = _cacheStore.getDocumentById(id);

      if (cachedDoc != null) {
        return Result.success(cachedDoc);
      }

      final apiDocument = await trashApiClient.getTrashDocument(id);
      if (apiDocument.isError()) {
        _log.severe("API error when fetching document with id $id");
        return Result.error(Exception("Failed to fetch document with id $id"));
      }
      final apiModel = apiDocument.tryGetSuccess()!;

      final document = Document(
        uuid: apiModel.uuid,
        titulo: apiModel.titulo,
        dataDocumento: apiModel.dataDocumento,
        medico: apiModel.nomeMedico,
        paciente: apiModel.nomePaciente,
        tipo: apiModel.tipoDocumento,
        deletedAt: apiModel.deletedAt,
        createdAt: apiModel.createdAt,
      );

      _cacheStore.saveDocuments([document]);

      return Success(document);
    });
  }

  @override
  Future<Result<List<Document>, Exception>> listTrashDocuments({
    forceRefresh = false,
  }) async {
    return _wrapThrow(() async {
      final cacheExpired =
          DateTime.now().difference(_cacheStore.updatedAt ?? DateTime(0)) >
          const Duration(hours: 1);
      if (!forceRefresh && !(_cacheStore.isEmpty || cacheExpired)) {
        return Result.success(_cacheStore.getAllDocuments());
      }

      final apiResult = await trashApiClient.listTrashDocuments();

      if (apiResult.isError()) {
        _log.severe("API error when fetching trash documents");
        return Result.error(Exception("Failed to fetch trash documents"));
      }

      // Store cache
      final documents = apiResult
          .tryGetSuccess()!
          .map(
            (e) => Document(
              uuid: e.uuid,
              titulo: e.titulo,
              dataDocumento: e.dataDocumento,
              medico: e.nomeMedico,
              paciente: e.nomePaciente,
              tipo: e.tipoDocumento,
              deletedAt: e.deletedAt,
              createdAt: e.createdAt,
            ),
          )
          .toList(growable: false);

      _cacheStore.saveDocuments(documents);

      return Result.success(documents);
    });
  }

  @override
  Future<Result<void, Exception>> restoreTrashDocument(String id) {
    return _wrapThrow(() async {
      final apiResult = await trashApiClient.restoreTrashDocument(id);
      if (apiResult.isError()) {
        _log.severe("API error when restoring document with id $id");
        return Result.error(
          Exception("Failed to restore document with id $id"),
        );
      }

      // Update local database to mark document as not deleted
      // First, get the document to preserve its metadata
      final docResult = await localDatabase.getDocument(id);
      if (docResult.isSuccess()) {
        final doc = docResult.tryGetSuccess();
        if (doc != null) {
          // Update the document with deletedAt set to null
          final updateResult = await localDatabase.upsertDocument(
            id,
            titulo: doc.titulo,
            paciente: doc.paciente,
            medico: doc.medico,
            tipo: doc.tipo,
            dataDocumento: doc.dataDocumento,
            createdAt: doc.createdAt,
            deletedAt: null, // Restore the document
            cachedAt: DateTime.now(),
          );
          if (updateResult.isError()) {
            _log.warning(
              "Failed to update document in local database after restore",
              updateResult.tryGetError()!,
            );
          }
        }
      } else {
        _log.warning(
          "Document not found in local database when trying to restore",
          docResult.tryGetError()!,
        );
      }

      // Remove from cache (no longer in trash)
      _cacheStore.removeDocument(id);
      notifyListeners();

      return const Success(null);
    });
  }

  Future<Result<T, Exception>> _wrapThrow<T>(
    Future<Result<T, Exception>> Function() func,
  ) async {
    try {
      return await func();
    } catch (e) {
      return Result.error(Exception("Unexpected error: $e"));
    }
  }
}

class _TrashCacheStore {
  // In-memory cache for trash documents
  final Map<String, Document> _documentCache = {};
  DateTime? _updatedAt;

  List<Document> getAllDocuments() => _documentCache.values.toList();

  Document? getDocumentById(String id) => _documentCache[id];

  void saveDocuments(List<Document> documents) {
    for (var doc in documents) {
      _documentCache[doc.uuid] = doc;
    }
    _updatedAt = DateTime.now();
  }

  void removeDocument(String id) {
    _documentCache.remove(id);
  }

  void clearCache() {
    _documentCache.clear();
  }

  bool get isEmpty => _documentCache.isEmpty;
  DateTime? get updatedAt => _updatedAt;
}

// TODO: Write local cache management class if necessary
