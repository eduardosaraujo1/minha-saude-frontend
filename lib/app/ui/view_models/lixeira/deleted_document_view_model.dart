import 'package:flutter/foundation.dart';
import 'package:minha_saude_frontend/app/data/models/document.dart';
import 'package:minha_saude_frontend/app/data/repositories/document_repository.dart';

class DeletedDocumentViewModel {
  Document? document;

  final DocumentRepository documentRepository;
  final String documentId;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<String?> redirectTo = ValueNotifier(null);

  DeletedDocumentViewModel(this.documentId, this.documentRepository) {
    _init();
  }

  Future<void> _init() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Fetch deleted document by id using documentRepository
      final result = await documentRepository.getDeletedDocumentById(
        documentId,
      );

      if (result.isSuccess()) {
        document = result.getOrThrow();
      } else {
        errorMessage.value =
            result.tryGetError()?.toString() ??
            'Erro desconhecido ao carregar documento';
      }
    } catch (e) {
      errorMessage.value = 'Erro ao carregar documento: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restoreDocument() async {
    // TODO: Implement repository method
    // This will restore the document from trash calling documentRepository
    redirectTo.value = '/lixeira';
  }

  Future<void> deleteDocumentPermanently() async {
    // TODO: Implement repository method
    // This will permanently delete the document calling documentRepository
    redirectTo.value = '/lixeira';
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
  }
}
