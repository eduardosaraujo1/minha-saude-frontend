import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/document/document.dart';
import '../../services/api/document/document_api_client.dart';
import '../../services/api/document/models/document_api_model.dart';
import '../../services/doc_scanner/document_scanner.dart';
import '../../services/local/cache_database/cache_database.dart';
import '../../services/local/cache_database/models/document_db_model.dart';
import '../../services/local/file_system_service/file_system_service.dart';
import 'cache/document_file_cache_store.dart';
import 'cache/document_list_cache_store.dart';
import 'document_repository.dart';

class DocumentRepositoryImpl extends DocumentRepository {
  DocumentRepositoryImpl({
    required DocumentApiClient documentApiClient,
    required CacheDatabase localDatabase,
    required DocumentScanner documentScanner,
    required FileSystemService fileSystemService,
    required DocumentListCacheStore documentListCache,
    required DocumentFileCacheStore documentFileCache,
  }) : _documentApiClient = documentApiClient,
       _localDatabase = localDatabase,
       _documentScanner = documentScanner,
       _fileSystemService = fileSystemService,
       _documentListCache = documentListCache,
       _documentFileCache = documentFileCache;

  final DocumentApiClient _documentApiClient;
  final DocumentScanner _documentScanner;
  final CacheDatabase _localDatabase;
  final FileSystemService _fileSystemService;
  final DocumentListCacheStore _documentListCache;
  final DocumentFileCacheStore _documentFileCache;

  final _log = Logger("DocumentRepositoryImpl");

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
    required String titulo,
    required String? paciente,
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

      final cacheResult = await _cacheDocumentInDatabase(apiDocument);
      if (cacheResult.isError()) {
        final error = cacheResult.tryGetError()!;
        _log.warning(
          "Failed to cache uploaded document metadata, but document is on remote",
          error,
        );
      }

      // Storing the file locally is not critical, so we log and move on if it fails
      Uint8List? fileBytes;
      try {
        fileBytes = await file.readAsBytes();
        final storeResult = await _fileSystemService.storeDocument(
          apiDocument.uuid,
          fileBytes,
        );

        if (storeResult.isError()) {
          final error = storeResult.tryGetError()!;
          _log.warning("Failed to store uploaded document locally", error);
        }
      } catch (e) {
        _log.warning("Failed to read uploaded file bytes for local storage", e);
      }

      _documentListCache.clear();
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
      // Check if the file is already cached
      final cachedFile = _documentFileCache.get(uuid);
      if (cachedFile != null) {
        return Result.success(cachedFile);
      }

      final localResult = await _fileSystemService.getDocument(uuid);

      if (localResult.isSuccess()) {
        // If file exists locally, cache and return it
        final localFile = localResult.tryGetSuccess();
        if (localFile != null) {
          _documentFileCache.set(uuid, localFile);
          return Result.success(localFile);
        }
      } else {
        _log.warning(
          "Failed to retrieve document from local storage",
          localResult.tryGetError()!,
        );
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
          "Failed to persist downloaded document bytes locally: placing in temp file",
          storeResult.tryGetError()!,
        );
        final file = await _writeBytesToTempFile(uuid, bytes);
        _documentFileCache.set(uuid, file);

        return Result.success(file);
      }

      // Return the stored file
      final storedFile = storeResult.tryGetSuccess()!;
      _documentFileCache.set(uuid, storedFile);

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
      // Read from local cache
      if (!forceRefresh) {
        final memoryDocument = _documentListCache.getByUuid(uuid);
        if (memoryDocument != null) {
          return Success(memoryDocument);
        }
      }

      // Read from local database
      final dbRead = await _localDatabase.getDocument(uuid);
      final DocumentDbModel? dbDocument = dbRead.tryGetSuccess();
      final bool isDbExpired =
          dbDocument?.isExpired(ttl: Duration(hours: 1)) ?? true;

      if (!forceRefresh && dbDocument != null && !isDbExpired) {
        return Success(_mapDbModelToDocument(dbDocument));
      }

      // If not found or expired, fetch from API
      _log.info("No cache hit for document metadata, fetching from API");
      final apiResult = await _documentApiClient.getDocument(uuid);

      if (apiResult.isError()) {
        final error = apiResult.tryGetError()!;

        if (dbDocument != null) {
          _log.warning(
            "API error fetching document metadata, returning stale database value",
            error,
          );
          return Result.success(_mapDbModelToDocument(dbDocument));
        }

        // No documents available to be served
        _log.severe("Failed to fetch document metadata", error);
        return Error(error);
      }

      final apiDocument = apiResult.tryGetSuccess()!;
      final cacheResponse = await _cacheDocumentInDatabase(apiDocument);
      if (cacheResponse.isError()) {
        _log.warning(
          "Failed to cache document metadata after API refresh",
          cacheResponse.tryGetError()!,
        );
      }

      return Success(_mapApiModelToDocument(apiDocument));
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
      // Attempt cache hit
      if (!forceRefresh) {
        final cachedList = _documentListCache.get();

        if (cachedList != null) {
          return Result.success(cachedList);
        }
      }

      // Fetch from API
      final apiResult = await _documentApiClient.listDocuments();
      List<Document> documents;
      if (apiResult.isSuccess()) {
        documents = apiResult
            .tryGetSuccess()!
            .where((apiDoc) => apiDoc.deletedAt == null)
            .map(_mapApiModelToDocument)
            .toList(growable: false);
      } else {
        _log.warning(
          "Failed to fetch document list from API: falling back to database",
          apiResult.tryGetError()!,
        );

        final dbDocuments = await _listLocalDocuments();

        if (dbDocuments.isError()) {
          final error = dbDocuments.tryGetError()!;
          _log.severe("Failed to list database documents", error);
          return Error(error);
        }

        documents = dbDocuments.tryGetSuccess()!;
      }

      // Update cache for future hits
      _documentListCache.set(documents);

      return Success(List.unmodifiable(documents));
    } on Exception catch (e, stackTrace) {
      _log.severe("Unexpected error listing documents", e, stackTrace);
      return Result.error(e);
    }
  }

  Future<Result<List<Document>, Exception>> _listLocalDocuments() async {
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

    return Result.success(List.unmodifiable(dbDocuments));
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
      final cacheResult = await _cacheDocumentInDatabase(apiDocument);
      if (cacheResult.isError()) {
        _log.warning(
          "Failed to update cached document metadata",
          cacheResult.tryGetError()!,
        );
      }

      _documentListCache.clear();
      notifyListeners();

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

      // await listDocuments(forceRefresh: true); // eager-loading
      _documentListCache.clear(); // lazy-loading
      notifyListeners();

      return Result.success(null);
    } on Exception catch (e, stackTrace) {
      _log.severe("Unexpected error moving document to trash", e, stackTrace);
      return Result.error(e);
    }
  }

  Future<Result<DocumentDbModel, Exception>> _cacheDocumentInDatabase(
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

  Future<File> _writeBytesToTempFile(String uuid, Uint8List bytes) async {
    final sanitizedUuid = uuid.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filePath = 'tmp_documents/document_$sanitizedUuid.pdf';
    return await _fileSystemService.writeTempFile(bytes, filePath);
  }

  @override
  Future<void> clearCache() async {
    _documentFileCache.clear();
    _documentListCache.clear();
    await _localDatabase.clear();
    await _fileSystemService.clearDocuments();
  }
}
