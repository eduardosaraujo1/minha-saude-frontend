import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/repositories/document/document_repository.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../config/asset.dart';
import '../../../domain/models/document/document.dart';

class DocumentViewModel {
  DocumentViewModel(this.documentUuid, this.documentRepository) {
    _loadDocument();
  }

  final String documentUuid;
  final DocumentRepository documentRepository;

  final errorMessage = ValueNotifier<String?>(null);
  final document = ValueNotifier<Document?>(null);
  final redirectTo = ValueNotifier<String?>(null);

  final documentLoadingStatus = ValueNotifier<DocumentLoadStatus>(
    DocumentLoadStatus.loading,
  );

  PdfControllerPinch? pdfController;

  Future<void> _loadDocument() async {
    documentLoadingStatus.value = DocumentLoadStatus.loading;
    // Load metadata
    final documentQuery = await documentRepository.getDocumentMeta(
      documentUuid,
    );

    if (documentQuery.isError()) {
      errorMessage.value = documentQuery.tryGetError()!.toString();
      documentLoadingStatus.value = DocumentLoadStatus.error;
      return;
    }

    // TODO: I have no idea what's going on
    // document.value = documentQuery.getOrThrow();

    // Load PDF
    pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset(Asset.fakeDocumentPdf),
    );

    documentLoadingStatus.value = DocumentLoadStatus.loaded;
  }

  void deleteDocument(String documentId) {
    // In a real implementation, you would call the repository to delete the document
    // await documentRepository.deleteDocument(documentId);

    // For now, just trigger navigation back to home
    redirectTo.value = '/';
  }

  void dispose() {
    pdfController?.dispose();
  }
}

enum DocumentAction { view, edit, delete }

enum DocumentLoadStatus { loading, loaded, error }
