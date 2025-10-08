import 'dart:io';

import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/utils/command.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../data/repositories/document/document_repository.dart';

class DocumentUploadViewModel {
  DocumentUploadViewModel(this._type, this._documentRepository) {
    loadDocument = Command0(_loadDocument);
    loadDocument.execute();
  }

  final DocumentRepository _documentRepository;
  final DocumentUploadMethod _type;
  final Logger _logger = Logger('DocumentUploadViewModel');

  File? uploadedFile;

  late final Command0<void, Exception> loadDocument;

  Future<Result<void, Exception>> _loadDocument() async {
    try {
      final result = switch (_type) {
        DocumentUploadMethod.scan =>
          await _documentRepository.scanDocumentFile(),
        DocumentUploadMethod.upload =>
          await _documentRepository.pickDocumentFile(),
      };

      if (result.isError()) {
        _logger.severe('Error loading document: ${result.tryGetError()}');
        return Result.error(
          Exception("Não foi possível carregar o documento."),
        );
      }

      uploadedFile = result.getOrThrow();

      return Result.success(null);
    } catch (e, s) {
      _logger.severe('Exception loading document:', e, s);
      return Result.error(
        Exception("Ocorreu um erro desconhecido ao carregar o documento."),
      );
    }
  }
}

enum DocumentUploadMethod { scan, upload }
