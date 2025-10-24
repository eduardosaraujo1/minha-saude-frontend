import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../config/asset.dart';
import 'document_scanner.dart';

class FakeDocumentScanner implements DocumentScanner {
  @override
  Future<File?> scanPdf() async {
    final blob = await rootBundle.load(Asset.fakeDocumentPdf);
    final tempDir = await getTemporaryDirectory();

    // Create the subdirectory if it doesn't exist
    final fakeDir = Directory("${tempDir.path}/fake");
    if (!await fakeDir.exists()) {
      await fakeDir.create(recursive: true);
    }

    final file = File("${fakeDir.path}/document.pdf");

    // Await the write operation to ensure the file is written before returning
    await file.writeAsBytes(
      blob.buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes),
      flush: true,
    );

    return file;
  }

  @override
  Future<List<File>> scanJpeg() async {
    return [];
  }
}
