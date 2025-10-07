import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/utils/command.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../data/repositories/document/document_repository.dart';

class DocumentUploadViewModel extends ChangeNotifier {
  // First calls the Repository to either call file uploader or scan document
  // Then, if successful, creates a PdfController to be used as a preview
  // Finally, SOMEHOW, needs to pass the file to the next step (DocumentInfoForm, unsure if go_router can send it)

  final DocumentRepository documentRepository;
  final DocumentCreateType _type;

  PageStatus _status = PageStatus.initial;
  String? _errorMessage;
  PdfController? _pdfController;

  PageStatus get status => _status;
  String? get errorMessage => _errorMessage;
  PdfController? get pdfController => _pdfController;

  late final Command0<void, Exception> loadDocument;

  DocumentUploadViewModel(this._type, this.documentRepository) {
    loadDocument = Command0(_loadDocument);
    loadDocument.execute();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<Result<void, Exception>> _loadDocument() async {
    _status = PageStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_type == DocumentCreateType.scan) {
        final result = await documentRepository.scanDocumentFile();

        if (result.isError()) {
          _status = PageStatus.error;
          _errorMessage = result.tryGetError()?.toString();
          notifyListeners();
          return Result.error(result.tryGetError()!);
        }

        _pdfController = PdfController(
          document: PdfDocument.openFile(result.getOrThrow().path),
        );
        _status = PageStatus.loaded;
        notifyListeners();
        return Result.success(null);
      } else if (_type == DocumentCreateType.upload) {
        final result = await documentRepository.pickDocumentFile();

        if (result.isError()) {
          _status = PageStatus.error;
          _errorMessage = result.tryGetError()?.toString();
          notifyListeners();
          return Result.error(result.tryGetError()!);
        }

        _pdfController = PdfController(
          document: PdfDocument.openFile(result.getOrThrow().path),
        );
        _status = PageStatus.loaded;
        notifyListeners();
        return Result.success(null);
      } else {
        _status = PageStatus.error;
        _errorMessage = 'Tipo de criação de documento inválido.';
        notifyListeners();
        return Result.error(
          Exception('Tipo de criação de documento inválido.'),
        );
      }
    } catch (e) {
      _status = PageStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return Result.error(Exception(e.toString()));
    }
  }
}

enum DocumentCreateType { scan, upload }

enum PageStatus { initial, loading, loaded, error }
