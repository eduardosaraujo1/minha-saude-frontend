import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minha_saude_frontend/app/data/document/models/document.dart';
import 'package:minha_saude_frontend/app/data/document/repositories/document_repository.dart';
import 'package:path_provider/path_provider.dart';

// TODO: If loading for more than 5 seconds, show error message
class DocumentViewModel {
  final String documentId;
  final DocumentRepository documentRepository;

  final errorMessage = ValueNotifier<String?>(null);
  final document = ValueNotifier<Document?>(null);

  late final Future<String> pdfPathFuture;

  DocumentViewModel(this.documentId, this.documentRepository) {
    _loadDocument();
    pdfPathFuture = _getAssetPdfPath('assets/fake/document.pdf');
  }

  Future<void> _loadDocument() async {
    final documentQuery = await documentRepository.getDocumentById(documentId);

    if (documentQuery.isError()) {
      errorMessage.value = documentQuery.tryGetError()!.toString();
      return;
    }

    document.value = documentQuery.getOrThrow();
  }

  // Placeholder for future network path loading functionality
  Future<String> _getAssetPdfPath(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_document.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (e) {
      throw Exception('Failed to load PDF from assets: $e');
    }
  }
}
