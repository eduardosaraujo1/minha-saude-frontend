import 'dart:io';
import 'dart:typed_data';

import 'package:multiple_result/multiple_result.dart';

abstract class FileSystemService {
  /// Opens a file picker dialog and allows the user to select a PDF file.
  Future<File?> pickPdfFile();

  /// Writes a temporary file with the given bytes and returns the file reference.
  Future<File> writeTempFile(Uint8List bytes, String filepath);

  /// Store a document in app-specific storage (applicationCache) with the provided UUID.
  /// Override any document if it already exists.
  Future<Result<File, Exception>> storeDocument(String uuid, Uint8List bytes);

  /// Retrieve a document file by its UUID from app-specific storage (applicationCache).
  Future<Result<File?, Exception>> getDocument(String uuid);

  /// Clear all documents from app-specific storage (applicationCache).
  Future<Result<void, Exception>> clearDocuments();
}
