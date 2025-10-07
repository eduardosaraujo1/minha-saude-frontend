import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/utils/cached_element/cached_element.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../services/api/document/document_api_client.dart';
import '../../services/api/document/models/document_api_model.dart';
import '../../services/doc_scanner/document_scanner.dart';
import '../../services/file_system_service/file_system_service.dart';
import '../../services/cache_database/cache_database.dart';
import '../../services/cache_database/models/document_db_model.dart';
import '../../../domain/models/document/document.dart';
import 'document_repository.dart';

class DocumentRepositoryImpl extends DocumentRepository {
  DocumentRepositoryImpl(
    this._documentApiClient,
    this._localDatabase,
    this._documentScanner,
    this._fileSystemService,
  );

  final DocumentApiClient _documentApiClient;
  final DocumentScanner _documentScanner;
  final CacheDatabase _localDatabase;
  final FileSystemService _fileSystemService;

  final _log = Logger("DocumentRepositoryImpl");

  CachedElement<List<Document>>? _documentListCache;

  @override
  Future<Result<File, Exception>> pickDocumentFile() async {
    try {
      final file = await _fileSystemService.pickPdfFile();

      if (file == null) {
        _log.warning("User canceled file picking");
        return Result.error(Exception("No file selected"));
      }

      return Result.success(file);
    } catch (e) {
      _log.severe("Error picking document file", e);
      return Result.error(Exception("Error picking document file"));
    }
  }

  @override
  Future<Result<File, Exception>> scanDocumentFile() async {
    try {
      final file = await _documentScanner.scanPdf();

      if (file == null) {
        _log.warning("User canceled document scanning");
        return Result.error(Exception("No file selected"));
      }

      return Result.success(file);
    } catch (e) {
      _log.severe("Error scanning document file", e);
      return Result.error(Exception("Error scanning document file"));
    }
  }

  @override
  Future<Result<Document, Exception>> uploadDocument(
    File file, {
    required String paciente,
    required String? titulo,
    required String? tipo,
    required String? medico,
    required DateTime? dataDocumento,
  }) async {
    try {
      final uploadResult = await _documentApiClient.uploadDocument(
        file: file,
        titulo: titulo,
        nomePaciente: paciente,
        nomeMedico: medico,
        tipoDocumento: tipo,
        dataDocumento: dataDocumento,
      );

      if (uploadResult.isError()) {
        final error = uploadResult.tryGetError()!;
        _log.severe("Failed to upload document", error);
        return Result.error(error);
      }

      final apiDocument = uploadResult.tryGetSuccess()!;
      final document = _mapApiModelToDocument(apiDocument);

      final cacheResult = await _cacheDocumentMetadata(apiDocument);
      if (cacheResult.isError()) {
        final error = cacheResult.tryGetError()!;
        _log.warning(
          "Failed to cache uploaded document metadata, but document is on remote",
          error,
        );
        return Result.success(document);
      }

      Uint8List fileBytes;
      try {
        fileBytes = await file.readAsBytes();
      } catch (e) {
        _log.warning("Failed to read uploaded file bytes for local storage", e);
        return Result.success(document);
      }

      final storeResult = await _fileSystemService.storeDocument(
        apiDocument.uuid,
        fileBytes,
      );

      if (storeResult.isError()) {
        final error = storeResult.tryGetError()!;
        _log.warning("Failed to store uploaded document locally", error);
        return Result.success(document);
      }

      _documentListCache = null;
      notifyListeners();

      return Result.success(document);
    } on Exception catch (e, stackTrace) {
      _log.severe("Unexpected error uploading document", e, stackTrace);
      return Result.error(e);
    }
  }

  @override
  Future<Result<File, Exception>> getDocumentFile(String uuid) async {
    try {
      final localResult = await _fileSystemService.getDocument(uuid);

      if (localResult.isError()) {
        _log.warning(
          "Failed to retrieve document from local storage",
          localResult.tryGetError()!,
        );
      }

      // If file exists locally, return it
      final localFile = localResult.tryGetSuccess();
      if (localFile != null) {
        return Result.success(localFile);
      }

      // Get file from remote and store locally ASAP
      final downloadResult = await _documentApiClient.downloadDocument(uuid);
      if (downloadResult.isError()) {
        final error = downloadResult.tryGetError()!;
        _log.severe("Failed to download document", error);
        return Result.error(error);
      }

      final bytes = downloadResult.tryGetSuccess()!;

      // Store the file locally
      final storeResult = await _fileSystemService.storeDocument(uuid, bytes);

      if (storeResult.isError()) {
        _log.warning(
          "Failed to persist downloaded document bytes locally: returning placing in temp file",
          storeResult.tryGetError()!,
        );
        final file = await _writeBytesToTempFile(uuid, bytes);

        return Result.success(file);
      }

      // Return the stored file
      final storedFile = storeResult.tryGetSuccess()!;

      return Result.success(storedFile);
    } on Exception catch (e, stackTrace) {
      _log.severe("Unexpected error fetching document file", e, stackTrace);
      return Result.error(e);
    }
  }

  @override
  Future<Result<Document, Exception>> getDocumentMeta(
    String uuid, {
    bool forceRefresh = false,
  }) async {
    try {
      final memoryDocument = _getDocumentFromMemory(uuid);
      if (!forceRefresh && memoryDocument != null) {
        return Result.success(memoryDocument);
      }

      DocumentDbModel? cachedModel;
      final cacheResult = await _localDatabase.getDocument(uuid);
      if (cacheResult.isError()) {
        _log.warning(
          "Unexpected error fetching document metadata from cache",
          cacheResult.tryGetError()!,
        );
      } else {
        cachedModel = cacheResult.tryGetSuccess();
        if (!forceRefresh &&
            cachedModel != null &&
            !_isDbMetadataCacheStale(cachedModel)) {
          return Result.success(_mapDbModelToDocument(cachedModel));
        }
      }

      final apiResult = await _documentApiClient.getDocument(uuid);
      if (apiResult.isError()) {
        final error = apiResult.tryGetError()!;
        if (cachedModel != null) {
          _log.warning(
            "API error fetching document metadata, returning cached value",
            error,
          );
          return Result.success(_mapDbModelToDocument(cachedModel));
        }

        _log.severe("Failed to fetch document metadata", error);
        return Result.error(error);
      }

      final apiDocument = apiResult.tryGetSuccess()!;
      final cacheResult2 = await _cacheDocumentMetadata(apiDocument);
      if (cacheResult2.isError()) {
        _log.warning(
          "Failed to cache document metadata after API refresh",
          cacheResult2.tryGetError()!,
        );
      }

      final document = _mapApiModelToDocument(apiDocument);

      await listDocuments(forceRefresh: true);

      return Result.success(document);
    } on Exception catch (e, stackTrace) {
      _log.severe(
        "Unexpected error retrieving document metadata",
        e,
        stackTrace,
      );
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<Document>, Exception>> listDocuments({
    bool forceRefresh = false,
  }) async {
    try {
      final cache = _documentListCache;
      if (!forceRefresh && cache != null) {
        if (!cache.isStale(maxAge: CachedElement.defaultMaxAge)) {
          return Result.success(List.unmodifiable(cache.data));
        }
      }

      final apiResult = await _documentApiClient.listDocuments();
      if (apiResult.isError()) {
        _log.warning(
          "Failed to fetch document list from API",
          apiResult.tryGetError()!,
        );

        final dbResult = await _localDatabase.listDocuments();
        if (dbResult.isError()) {
          final error = dbResult.tryGetError()!;
          _log.severe("Failed to fetch document list from cache", error);
          return Result.error(error);
        }

        final dbDocuments = dbResult
            .tryGetSuccess()!
            .where((dbDoc) => dbDoc.deletedAt == null)
            .map(_mapDbModelToDocument)
            .toList(growable: false);

        final immutableDocs = List<Document>.unmodifiable(dbDocuments);
        _documentListCache = CachedElement(immutableDocs);
        notifyListeners();
        return Result.success(immutableDocs);
      }

      final apiDocuments = apiResult.tryGetSuccess()!;
      final documents = apiDocuments
          .where((apiDoc) => apiDoc.deletedAt == null)
          .map(_mapApiModelToDocument)
          .toList(growable: false);

      final immutableDocs = List<Document>.unmodifiable(documents);
      _documentListCache = CachedElement(immutableDocs);
      notifyListeners();

      return Result.success(immutableDocs);
    } on Exception catch (e, stackTrace) {
      _log.severe("Unexpected error listing documents", e, stackTrace);
      return Result.error(e);
    }
  }

  @override
  Future<Result<Document, Exception>> updateDocument(
    String uuid, {
    String? titulo,
    String? paciente,
    String? tipo,
    String? medico,
    DateTime? dataDocumento,
  }) async {
    try {
      final apiResult = await _documentApiClient.updateDocument(
        uuid,
        titulo: titulo,
        nomePaciente: paciente,
        nomeMedico: medico,
        tipoDocumento: tipo,
        dataDocumento: dataDocumento,
      );

      if (apiResult.isError()) {
        final error = apiResult.tryGetError()!;
        _log.severe("Failed to update document metadata", error);
        return Result.error(error);
      }

      final apiDocument = apiResult.tryGetSuccess()!;
      final cacheResult = await _cacheDocumentMetadata(apiDocument);
      if (cacheResult.isError()) {
        _log.warning(
          "Failed to update cached document metadata",
          cacheResult.tryGetError()!,
        );
      }

      await listDocuments(forceRefresh: true);

      return Result.success(_mapApiModelToDocument(apiDocument));
    } on Exception catch (e, stackTrace) {
      _log.severe("Unexpected error updating document metadata", e, stackTrace);
      return Result.error(e);
    }
  }

  @override
  Future<Result<void, Exception>> moveToTrash(String uuid) async {
    try {
      final remoteResult = await _documentApiClient.trashDocument(uuid);
      if (remoteResult.isError()) {
        final error = remoteResult.tryGetError()!;
        _log.severe("Failed to move document to trash on server", error);
        return Result.error(error);
      }

      final cacheResult = await _localDatabase.trashDocument(uuid);
      if (cacheResult.isError()) {
        final error = cacheResult.tryGetError()!;
        _log.warning("Failed to update cached document trash status", error);
        return Result.error(error);
      }

      await listDocuments(forceRefresh: true);

      return Result.success(null);
    } on Exception catch (e, stackTrace) {
      _log.severe("Unexpected error moving document to trash", e, stackTrace);
      return Result.error(e);
    }
  }

  Future<Result<DocumentDbModel, Exception>> _cacheDocumentMetadata(
    DocumentApiModel apiModel,
  ) {
    return _localDatabase.upsertDocument(
      apiModel.uuid,
      titulo: apiModel.titulo,
      paciente: apiModel.nomePaciente,
      medico: apiModel.nomeMedico,
      tipo: apiModel.tipoDocumento,
      dataDocumento: apiModel.dataDocumento,
      createdAt: apiModel.createdAt,
      deletedAt: apiModel.deletedAt,
      cachedAt: DateTime.now(),
    );
  }

  Document _mapApiModelToDocument(DocumentApiModel apiModel) {
    return Document(
      uuid: apiModel.uuid,
      paciente: apiModel.nomePaciente,
      titulo: apiModel.titulo,
      tipo: apiModel.tipoDocumento,
      medico: apiModel.nomeMedico,
      dataDocumento: apiModel.dataDocumento,
      createdAt: apiModel.createdAt,
      deletedAt: apiModel.deletedAt,
    );
  }

  Document _mapDbModelToDocument(DocumentDbModel dbModel) {
    return Document(
      uuid: dbModel.uuid,
      paciente: dbModel.paciente,
      titulo: dbModel.titulo,
      tipo: dbModel.tipo,
      medico: dbModel.medico,
      dataDocumento: dbModel.dataDocumento,
      createdAt: dbModel.createdAt,
      deletedAt: dbModel.deletedAt,
    );
  }

  bool _isDbMetadataCacheStale(DocumentDbModel model) {
    final age = DateTime.now().difference(model.cachedAt);
    return age > CachedElement.defaultMaxAge;
  }

  Document? _getDocumentFromMemory(String uuid) {
    final cache = _documentListCache;
    if (cache == null) {
      return null;
    }

    if (cache.isStale(maxAge: CachedElement.defaultMaxAge)) {
      return null;
    }

    for (final document in cache.data) {
      if (document.uuid == uuid) {
        return document;
      }
    }

    return null;
  }

  Future<File> _writeBytesToTempFile(String uuid, Uint8List bytes) async {
    final sanitizedUuid = uuid.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filePath =
        '${Directory.systemTemp.path}${Platform.pathSeparator}document_$sanitizedUuid.pdf';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}

class _DocumentListCache {
  // In-memory cache for document list to avoid frequent database queries
  // May be refreshed from database or API by the repository through a method call
  // Has defined expiration date controlled by CachedElement
  // Has query methods like getByUuid, previously implemented on the repository directly
}
