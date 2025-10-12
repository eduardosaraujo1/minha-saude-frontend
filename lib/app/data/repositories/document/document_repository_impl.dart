import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../utils/cached_element/cached_element.dart';
import '../../services/api/document/document_api_client.dart';
import '../../services/api/document/models/document_api_model.dart';
import '../../services/doc_scanner/document_scanner.dart';
import '../../services/local/file_system_service/file_system_service.dart';
import '../../services/local/cache_database/cache_database.dart';
import '../../services/local/cache_database/models/document_db_model.dart';
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

  final _documentListCache = _InMemoryDocumentListCache();
  final _documentFileCache = _InMemoryDocumentFileCache();

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
          "Failed to persist downloaded document bytes locally: returning placing in temp file",
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
      DocumentDbModel? cachedModel;
      if (!forceRefresh) {
        final memoryDocument = _documentListCache.getByUuid(uuid);
        if (memoryDocument != null) {
          return Result.success(memoryDocument);
        }

        final dbReadResult = await _localDatabase.getDocument(uuid);
        if (dbReadResult.isError()) {
          _log.warning(
            "Unexpected error fetching document metadata from cache",
            dbReadResult.tryGetError()!,
          );
        } else {
          // Reading from CacheDatabase was successful
          cachedModel = dbReadResult.tryGetSuccess();
          if (cachedModel != null &&
              !cachedModel.isStale(ttl: Duration(hours: 1))) {
            return Result.success(_mapDbModelToDocument(cachedModel));
          }
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
      // Guard clause: return cached list if available and not forcing refresh
      if (!forceRefresh) {
        final cachedList = _documentListCache.get();
        if (cachedList != null) {
          return Result.success(cachedList);
        }
      }

      // Try to fetch from API
      final apiResult = await _documentApiClient.listDocuments();
      if (apiResult.isSuccess()) {
        return _handleSuccessfulApiResponse(apiResult.tryGetSuccess()!);
      }

      // API failed, log and fall back to database
      _log.warning(
        "Failed to fetch document list from API",
        apiResult.tryGetError()!,
      );
      return _handleApiFallbackToDatabase();
    } on Exception catch (e, stackTrace) {
      _log.severe("Unexpected error listing documents", e, stackTrace);
      return Result.error(e);
    }
  }

  Future<Result<List<Document>, Exception>> _handleSuccessfulApiResponse(
    List<DocumentApiModel> apiDocuments,
  ) async {
    final documents = apiDocuments
        .where((apiDoc) => apiDoc.deletedAt == null)
        .map(_mapApiModelToDocument)
        .toList(growable: false);

    return _updateCacheAndNotify(documents);
  }

  Future<Result<List<Document>, Exception>>
  _handleApiFallbackToDatabase() async {
    final dbDocumentsResult = await _listDbDocuments();

    if (dbDocumentsResult.isError()) {
      final error = dbDocumentsResult.tryGetError()!;
      _log.severe("Failed to fetch document list from cache", error);
      return Result.error(error);
    }

    final dbDocuments = dbDocumentsResult.tryGetSuccess()!;
    return _updateCacheAndNotify(dbDocuments);
  }

  Result<List<Document>, Exception> _updateCacheAndNotify(
    List<Document> documents,
  ) {
    _documentListCache.set(documents);
    notifyListeners();
    return Result.success(List.unmodifiable(documents));
  }

  Future<Result<List<Document>, Exception>> _listDbDocuments() async {
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
      final cacheResult = await _cacheDocumentMetadata(apiDocument);
      if (cacheResult.isError()) {
        _log.warning(
          "Failed to update cached document metadata",
          cacheResult.tryGetError()!,
        );
      }

      // await listDocuments(forceRefresh: true); // eager-loading
      _documentListCache.clear(); // lazy-loading
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

  Future<File> _writeBytesToTempFile(String uuid, Uint8List bytes) async {
    final sanitizedUuid = uuid.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filePath = 'tmp_documents/document_$sanitizedUuid.pdf';
    return await _fileSystemService.writeTempFile(bytes, filePath);
  }

  @override
  Future<void> resetCache() async {
    _documentListCache.clear();
    await _localDatabase.clear();
  }
}

class _InMemoryDocumentListCache {
  CachedElement<List<Document>>? _cache;

  /// Returns true if the cache exists and is not stale
  bool isValid() {
    final cache = _cache;
    if (cache == null) {
      return false;
    }
    return !cache.isStale(maxAge: CachedElement.defaultMaxAge);
  }

  /// Returns the cached list if it exists and is valid, otherwise null
  List<Document>? get() {
    if (!isValid()) {
      return null;
    }
    return _cache?.data;
  }

  /// Stores a new list in the cache
  void set(List<Document> documents) {
    _cache = CachedElement(List.unmodifiable(documents));
  }

  /// Clears the cache
  void clear() {
    _cache = null;
  }

  /// Retrieves a document by UUID from the cache if available
  Document? getByUuid(String uuid) {
    if (!isValid()) {
      return null;
    }

    final data = _cache?.data;
    if (data == null) {
      return null;
    }

    for (final document in data) {
      if (document.uuid == uuid) {
        return document;
      }
    }

    return null;
  }
}

class _InMemoryDocumentFileCache {
  String? _cachedUuid;
  File? _cachedFile;

  /// Returns the cached file if the UUID matches, otherwise null
  File? get(String uuid) {
    if (_cachedUuid == uuid && _cachedFile != null) {
      return _cachedFile;
    }
    return null;
  }

  /// Stores a file and its UUID in the cache
  void set(String uuid, File file) {
    _cachedUuid = uuid;
    _cachedFile = file;
  }

  /// Clears the cache
  void clear() {
    _cachedUuid = null;
    _cachedFile = null;
  }
}
