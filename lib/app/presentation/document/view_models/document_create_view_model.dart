import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/document/repositories/document_upload_repository.dart';

class DocumentCreateViewModel {
  final DocumentUploadRepository uploadRepository;
  final DocumentCreateType _type;

  final isLoading = ValueNotifier<bool>(true);
  final errorMessage = ValueNotifier<String?>(null);
  final documentFile = ValueNotifier<DocumentFile?>(null);

  DocumentCreateViewModel(this._type, this.uploadRepository) {
    _getDocument();
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
  }

  void _getDocument() async {
    isLoading.value = true;

    if (_type == DocumentCreateType.scan) {
      final result = await uploadRepository.scanDocument();

      if (result.isError()) {
        errorMessage.value = result.tryGetError()?.toString();
      } else {
        documentFile.value = result.getOrThrow();
      }
      isLoading.value = false;
    } else if (_type == DocumentCreateType.upload) {
      final result = await uploadRepository.uploadDocumentFromFile();

      if (result.isError()) {
        errorMessage.value = result.tryGetError()?.toString();
      }
      isLoading.value = false;
    }
  }
}

enum DocumentCreateType { scan, upload }
