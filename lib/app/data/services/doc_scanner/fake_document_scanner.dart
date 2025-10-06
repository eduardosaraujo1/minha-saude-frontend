import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../config/asset.dart';
import 'document_scanner.dart';

class FakeDocumentScanner implements DocumentScanner {
  @override
  Future<File?> scanPdf() async {
    final blob = await rootBundle.load(Asset.fakeDocumentPdf);
    final tempDir = await getTemporaryDirectory();

    final file = File("${tempDir.path}/fake/document.pdf");
    file.writeAsBytes(
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
