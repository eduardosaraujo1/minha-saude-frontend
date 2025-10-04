import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:minha_saude_frontend/app/data/repositories/document/document_repository.dart';

class LixeiraViewModel {
  DocumentRepository documentRepository;

  // State management with ValueNotifiers
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  List<Document> _deletedDocuments = [];

  List<Document> get deletedDocuments =>
      UnmodifiableListView(_deletedDocuments);

  LixeiraViewModel(this.documentRepository) {
    _init();
    // TODO: Listen to documentRepository for changes (rerun _init)
  }

  Future<void> _init() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await documentRepository.listDeletedDocuments();

      if (result.isSuccess()) {
        _deletedDocuments = result.getOrThrow();
      } else {
        errorMessage.value =
            result.tryGetError()?.toString() ??
            'Erro desconhecido ao carregar documentos';
      }
    } catch (e) {
      errorMessage.value = 'Erro ao carregar documentos: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void clearErrorMessage() {
    errorMessage.value = null;
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
  }
}
