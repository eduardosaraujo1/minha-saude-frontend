import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/utils/command.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../data/repositories/document/document_repository.dart';
import '../../../../domain/models/document/document.dart';
import 'document_info_form_model.dart';

class DocumentUploadViewModel {
  DocumentUploadViewModel(this._type, this._documentRepository) {
    loadDocument = Command0(_loadDocument);
    uploadDocument = Command0(_uploadDocument);
    loadDocument.execute();
  }

  final DocumentRepository _documentRepository;
  final DocumentUploadMethod _type;
  final Logger _logger = Logger('DocumentUploadViewModel');

  File? uploadedFile;
  DocumentFormData? _formData;
  final currentStep = ValueNotifier<UploadStep>(UploadStep.preview);

  late final Command0<void, Exception> loadDocument;
  late final Command0<Document, Exception> uploadDocument;

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

  Future<Result<Document, Exception>> _uploadDocument() async {
    if (uploadedFile == null) {
      _logger.severe('No file uploaded when trying to upload document.');
      return Result.error(Exception("Nenhum arquivo foi carregado."));
    }

    if (_formData == null) {
      _logger.severe('No form data provided when trying to upload document.');
      return Result.error(
        Exception("Nenhum dado do formulário foi fornecido."),
      );
    }

    try {
      final result = await _documentRepository.uploadDocument(
        uploadedFile!,
        paciente: _formData!.nomePaciente ?? '',
        titulo: _formData!.titulo,
        tipo: _formData!.tipoDocumento,
        medico: _formData!.nomeMedico,
        dataDocumento: _formData!.dataDocumento,
      );

      if (result.isError()) {
        _logger.severe('Error uploading document: ${result.tryGetError()}');
        return Result.error(
          Exception("Não foi possível fazer upload do documento."),
        );
      }

      return result;
    } catch (e, s) {
      _logger.severe('Exception uploading document:', e, s);
      return Result.error(
        Exception("Ocorreu um erro desconhecido ao fazer upload do documento."),
      );
    }
  }

  void goToForm() {
    currentStep.value = UploadStep.form;
  }

  void goBackToPreview() {
    currentStep.value = UploadStep.preview;
  }

  void handleFormSubmit(DocumentFormData formData) {
    _formData = formData;
    uploadDocument.execute();
  }

  void dispose() {
    currentStep.dispose();
  }
}

enum DocumentUploadMethod { scan, upload }

enum UploadStep { preview, form }
