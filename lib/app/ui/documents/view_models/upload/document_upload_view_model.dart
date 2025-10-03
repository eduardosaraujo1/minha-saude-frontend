import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/repositories/document_upload_repository.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../../config/asset.dart';

class DocumentUploadViewModel {
  final DocumentUploadRepository uploadRepository;
  final DocumentCreateType _type;

  final status = ValueNotifier<PageStatus>(PageStatus.initial);
  final errorMessage = ValueNotifier<String?>(null);

  PdfController? _pdfController;

  PdfController? get pdfController => _pdfController;

  DocumentUploadViewModel(this._type, this.uploadRepository) {
    _getDocument();
  }

  void dispose() {
    // status.dispose();
    // errorMessage.dispose();
    // _pdfController?.dispose();
  }

  void _getDocument() async {
    status.value = PageStatus.loading;

    if (_type == DocumentCreateType.scan) {
      // mock decision
      //   DocumentCreateMode.scan) {
      // final result = await uploadRepository.scanDocument();

      // if (result.isError()) {
      //   status.value = PageStatus.error;
      //   errorMessage.value = result.tryGetError()?.toString();
      // } else {
      //   _pdfController = PdfController(
      //     document: PdfDocument.openFile(result.getOrThrow().path),
      //   );
      // }
      // Mock:
      _pdfController = PdfController(
        document: PdfDocument.openAsset(Asset.fakeDocumentPdf),
      );
      status.value = PageStatus.loaded;
    } else if (_type == DocumentCreateType.upload) {
      final result = await uploadRepository.uploadDocumentFromFile();

      if (result.isError()) {
        status.value = PageStatus.error;
        errorMessage.value = result.tryGetError()?.toString();
      }
      status.value = PageStatus.loaded;
    } else {
      status.value = PageStatus.error;
      errorMessage.value = 'Tipo de criação de documento inválido.';
    }
  }
}

enum DocumentCreateType { scan, upload }

enum PageStatus { initial, loading, loaded, error }
