import 'dart:io';

import 'package:multiple_result/multiple_result.dart';

abstract class FileSystemService {
  /// Opens a file picker dialog and allows the user to select a PDF file.
  Future<File?> pickPdfFile();

  /// Store a document in app-specific storage (documentStorage) with the provided UUID.
  /// Override any document if it already exists.
  Future<Result<void, Exception>> storeDocument(String uuid);

  /// Retrieve a document file by its UUID from app-specific storage (documentStorage).
  Future<Result<File, Exception>> getDocument(String uuid);

  /// Clear all documents from app-specific storage (documentStorage).
  Future<Result<void, Exception>> clearDocuments();
}
