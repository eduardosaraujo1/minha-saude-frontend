import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/domain/models/document.dart';
import 'package:minha_saude_frontend/app/data/repositories/document_repository.dart';
import 'package:pdfx/pdfx.dart';

// TODO: If loading for more than 5 seconds, show error message
class DocumentViewModel {
  final String documentId;
  final DocumentRepository documentRepository;

  final errorMessage = ValueNotifier<String?>(null);
  final document = ValueNotifier<Document?>(null);
  final redirectTo = ValueNotifier<String?>(null);

  final documentLoadingStatus = ValueNotifier<DocumentLoadStatus>(
    DocumentLoadStatus.loading,
  );

  PdfControllerPinch? pdfController;

  DocumentViewModel(this.documentId, this.documentRepository) {
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    documentLoadingStatus.value = DocumentLoadStatus.loading;
    // Load metadata
    final documentQuery = await documentRepository.getDocumentById(documentId);

    if (documentQuery.isError()) {
      errorMessage.value = documentQuery.tryGetError()!.toString();
      documentLoadingStatus.value = DocumentLoadStatus.error;
      return;
    }

    document.value = documentQuery.getOrThrow();

    // Load PDF
    pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/fake/document.pdf'),
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
