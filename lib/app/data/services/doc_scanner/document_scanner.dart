import 'dart:io';

export 'fake_document_scanner.dart';
export 'document_scanner_impl.dart';

abstract class DocumentScanner {
  /// Scan PDF file using google_ml_kit
  Future<File?> scanPdf();

  /// Scan JPEG image using google_ml_kit
  Future<List<File>> scanJpeg();
}
