/*
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../data/repositories/document/document_repository.dart';
import '../../../../../config/asset.dart';

class DocumentUploadViewModel {
  // First calls the Repository to either call file uploader or scan document
  // Then, if successful, creates a PdfController to be used as a preview
  // Finally, SOMEHOW, needs to pass the file to the next step (DocumentInfoForm, unsure if go_router can send it)

  final DocumentRepository documentRepository;
  final DocumentCreateType _type;

  final status = ValueNotifier<PageStatus>(PageStatus.initial);
  final errorMessage = ValueNotifier<String?>(null);

  PdfController? _pdfController;

  PdfController? get pdfController => _pdfController;

  DocumentUploadViewModel(this._type, this.documentRepository) {
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
      final result = await documentRepository.uploadDocument();

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
*/
