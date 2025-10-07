import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/document/document.dart';

/// Repository interface for managing documents, including uploading, fetching,
/// editing, and deleting documents. It abstracts the underlying data sources,
/// such as remote APIs and local databases.
///
/// This repository should handle caching through the CacheDatabase service to ensure
/// offline access to document metadata, and FileSystemService to store document files.
abstract class DocumentRepository extends ChangeNotifier {
  // [DOCUMENT QUERY FROM USER]
  /// Get document file from file picker
  Future<Result<File, Exception>> pickDocumentFile();

  /// Get document file from scanner
  Future<Result<File, Exception>> scanDocumentFile();

  // [DOCUMENT UPLOAD]
  /// Upload document file with metadata to server
  /// Also stored document metadata locally through LocalDatabase, only if the server
  /// upload is successful.
  Future<Result<Document, Exception>> uploadDocument(
    File file, {
    required String paciente,
    required String? titulo,
    required String? tipo,
    required String? medico,
    required DateTime? dataDocumento,
  });

  // [DOCUMENT READING AND LISTING]
  /// List documents stored locally and remotely with metadata and file path (Document model)
  /// TODO: Pagination is not implemented yet
  Future<Result<List<Document>, Exception>> listDocuments({
    bool forceRefresh = false,
  });

  /// Get single document by id with metadata (Document model)
  Future<Result<Document, Exception>> getDocumentMeta(
    String uuid, {
    bool forceRefresh = false,
  });

  /// Get single document by id with metadata (Document model)
  Future<Result<File, Exception>> getDocumentFile(String uuid);

  // [DOCUMENT EDITING AND DELETION]
  /// Edit document metadata on server and update local cache, returns updated Document model
  Future<Result<Document, Exception>> updateDocument(
    String uuid, {
    String? titulo,
    String? paciente,
    String? tipo,
    String? medico,
    DateTime? dataDocumento,
  });

  /// Move document to trash on server and update local cache
  /// Document is not deleted permanently, it can be restored
  Future<Result<void, Exception>> moveToTrash(String uuid);
}
