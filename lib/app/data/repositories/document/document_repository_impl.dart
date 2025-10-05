import 'dart:io';

import 'package:logging/logging.dart';
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
  Future<Result<Document, Exception>> updateDocument(
    String id, {
    String? titulo,
    String? paciente,
    String? tipo,
    String? medico,
    DateTime? dataDocumento,
  }) {
    // TODO: implement editDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<File, Exception>> getDocumentFile(String id) {
    // TODO: implement getDocumentFile
    throw UnimplementedError();
  }

  @override
  Future<Result<Document, Exception>> getDocumentMeta(String id) {
    // TODO: implement getDocumentMeta
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Document>, Exception>> listDocuments({
    bool forceRefresh = false,
  }) {
    // TODO: implement listDocuments
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> moveToTrash(String id) {
    // TODO: implement moveToTrash
    throw UnimplementedError();
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
    // TODO: implement uploadDocument
    throw UnimplementedError();
  }
}
