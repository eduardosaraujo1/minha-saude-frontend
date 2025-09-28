import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/repositories/share_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/document.dart';

class VisualizarDocumentosViewModel {
  VisualizarDocumentosViewModel(this.shareRepository) {
    refresh();
  }

  final ShareRepository shareRepository;

  final documents = ValueNotifier<List<Document>>([]);

  final errorMessage = ValueNotifier<String?>(null);
  final isLoading = ValueNotifier<bool>(false);

  Future<void> refresh() async {
    try {
      isLoading.value = true;
      final documentsQuery = await shareRepository.listSharedDocuments(
        "all",
      ); // all is not actually valid, just for now that it's mocked

      if (documentsQuery.isError()) {
        errorMessage.value = documentsQuery.tryGetError()!.toString();
        return;
      }

      documents.value = documentsQuery.getOrThrow();
    } finally {
      isLoading.value = false;
    }
  }
}
