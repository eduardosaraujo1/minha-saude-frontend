import 'dart:io';

import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/utils/cached_element/cached_element.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../services/api/document/document_api_client.dart';
import '../../services/doc_scanner/document_scanner.dart';
import '../../services/file_system_service/file_system_service.dart';
import '../../services/cache_database/cache_database.dart';
import '../../../domain/models/document/document.dart';
import 'document_repository.dart';

class DocumentRepositoryImpl extends DocumentRepository {
  DocumentRepositoryImpl(
    this._documentApiClient,
    this._localDatabase,
    this._documentScanner,
    this._filePickerService,
  );

  final DocumentApiClient _documentApiClient;
  final CacheDatabase _localDatabase;
  final DocumentScanner _documentScanner;
  final FileSystemService _filePickerService;

  final _log = Logger("DocumentRepositoryImpl");

  CachedElement<List<Document>>? _documentListCache;

  @override
  Future<Result<File, Exception>> pickDocumentFile() async {
    try {
      final file = await _filePickerService.pickPdfFile();

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
  Future<Result<void, Exception>> uploadDocument(
    File file, {
    required String paciente,
    required String? titulo,
    required String? tipo,
    required String? medico,
    required DateTime? dataDocumento,
  }) {
    // 1. Upload document to API, retreiving DocumentApiModel

    // 2. Store metadata in local database

    // 3. Store file locally using UUID from the DocumentApiModel

    // Always use try/catch to return Result.error on exceptions for handling on ui
    throw UnimplementedError();
  }

  @override
  Future<Result<File, Exception>> getDocumentFile(String uuid) {
    // 1. Query cache database for document metadata using UUID
    //    - Guard: If cache entry doesn't exist -> call getDocumentMeta(uuid) to
    //update cache and store in variable

    // 2. Check if file exists locally using FileSystemService with UUID
    //    - Store result as boolean for later use

    // 3. Guard: If cache is not stale (expired) and local file exists
    // -> return local file immediately (cache hit)

    // 4. Download document from API using UUID
    //    - Guard: If download fails -> check if we have file as fallback
    //      - If fallback exists -> log warning and return stale cached file
    //      - If no fallback -> return error

    // 5. Save downloaded file to FileSystemService using UUID
    //    - Guard: If save fails -> log error but still return downloaded file (don't fail the request)

    // 7. Return the downloaded file

    throw UnimplementedError();
  }

  @override
  Future<Result<Document, Exception>> getDocumentMeta(String uuid) {
    // 1. Query cache database for document metadata using UUID

    // 2. If cache exists and is not stale -> return cached metadata (cache hit)

    // 3. Fetch document metadata from API using UUID

    // 4. Store or update metadata in cache database with new data and current timestamp

    // TODO: implement getDocumentMeta
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Document>, Exception>> listDocuments({
    bool forceRefresh = false,
  }) {
    // 1. If we have a cached list and it's not stale and forceRefresh is false
    // -> return cached list (cache hit)

    // 2. Fetch document list from API
    //    - Guard: If fetch fails -> log and return error

    // 3. Store or update document list in cache database with new data and current timestamp

    throw UnimplementedError();
  }

  @override
  Future<Result<Document, Exception>> updateDocument(
    String uuid, {
    String? titulo,
    String? paciente,
    String? tipo,
    String? medico,
    DateTime? dataDocumento,
  }) {
    // 1. Send update request to API with new metadata
    //    - Guard: If update fails -> log and return error

    // 2. Update metadata in cache database with new data and current timestamp

    // 3. Return updated Document model
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> moveToTrash(String uuid) {
    // 1. Send delete request to API to move document to trash
    //    - Guard: If update fails -> log and return error

    // 2. Update metadata in cache database to reflect trashed status and current timestamp
    throw UnimplementedError();
  }
}
