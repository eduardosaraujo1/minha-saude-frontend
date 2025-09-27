import 'dart:io';
import 'package:doc_scan_flutter/doc_scan.dart' as pl;

class DocumentScanner {
  Future<File?> scanPdf() async {
    final result = await pl.DocumentScanner.scan(format: pl.DocScanFormat.pdf);

    if (result == null || result.isEmpty) {
      return null;
    }

    final docPath = result.first;
    final file = File(docPath);

    // Validate if file exists before returning
    final fileExists = await file.exists();
    if (!fileExists) {
      return null;
    }

    return file;
  }

  Future<List<File>> scanJpeg() async {
    final result = await pl.DocumentScanner.scan(format: pl.DocScanFormat.jpeg);

    if (result == null || result.isEmpty) {
      return [];
    }

    final List<File> validFiles = [];

    // Check each file path and only include files that exist
    for (final path in result) {
      final file = File(path);
      if (await file.exists()) {
        validFiles.add(file);
      }
    }

    return validFiles;
  }
}
