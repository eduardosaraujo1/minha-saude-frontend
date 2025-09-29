import 'dart:io';

abstract class DocumentScanner {
  /// Scan PDF file using google_ml_kit
  Future<File?> scanPdf();

  /// Scan JPEG image using google_ml_kit
  Future<List<File>> scanJpeg();
}
