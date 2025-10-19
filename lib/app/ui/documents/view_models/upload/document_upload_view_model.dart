import 'dart:io';

import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../data/repositories/document/document_repository.dart';
import '../../../view_model.dart';

class DocumentUploadViewModel extends ViewModel {
  DocumentUploadViewModel({
    required DocumentUploadMethod type,
    required DocumentRepository documentRepository,
  }) : _documentRepository = documentRepository,
       _type = type {
    getDocumentCommand = Command.createAsyncNoParam(
      _getDocument,
      initialValue: null,
    );
    uploadDocument = Command.createAsync(
      _uploadDocument, //
      initialValue: null,
    );
  }

  final Logger _logger = Logger('DocumentUploadViewModel');
  final DocumentRepository _documentRepository;
  final DocumentUploadMethod _type;

  /// Gets the document to be uploaded through the selected method:
  /// - If the method is [DocumentUploadMethod.docScanner], it will use the scanner to get the document
  /// - If the method is [DocumentUploadMethod.filePicker], it will use the file picker to get the document
  ///
  /// Returns uploaded [File] on success, or an [Exception] on failure.
  late final Command<void, Result<File, Exception>?> getDocumentCommand;

  /// Uploads the document with the provided metadata and file to server.
  late final Command<DocumentUploadRequest, Result<void, Exception>?>
  uploadDocument;

  /// Title of the document being uploaded (set in the UI).
  final ValueNotifier<String?> documentTitle = ValueNotifier(null);

  /// Holds the current step of the upload process.
  ///
  /// Used for navigation between steps in the UI.
  final ValueNotifier<UploadStep> currentStep = ValueNotifier<UploadStep>(
    UploadStep.preview,
  );

  Future<Result<File, Exception>> _getDocument() async {
    try {
      switch (_type) {
        case DocumentUploadMethod.docScanner:
          return await _documentRepository.scanDocumentFile();
        case DocumentUploadMethod.filePicker:
          return await _documentRepository.pickDocumentFile();
      }
    } catch (e, s) {
      _logger.severe('Exception getting document:', e, s);
      return Result.error(Exception('Erro ao obter o documento: $e'));
    }
  }

  Future<Result<void, Exception>> _uploadDocument(
    DocumentUploadRequest request,
  ) async {
    try {
      final result = await _documentRepository.uploadDocument(
        request.file,
        titulo: request.titulo,
        paciente: request.paciente,
        medico: request.medico,
        tipo: request.tipo,
        dataDocumento: request.dataDocumento,
      );

      if (result.isError()) {
        _logger.severe('Error uploading document: ${result.tryGetError()}');
        return Error(Exception('Não foi possível enviar o documento.'));
      }

      return Success(null);
    } catch (e, s) {
      _logger.severe('Exception uploading document:', e, s);
      return Error(
        Exception('Ocorreu um erro desconhecido ao enviar o documento.'),
      );
    }
  }

  /// Uploads the document with the provided metadata and current viewModel state.
  ///
  /// Returns [Success] on successful upload initiation, or [Error] if validation fails.
  Result<void, Exception> triggerUploadWithMetadata({
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  }) {
    try {
      final title = documentTitle.value;
      if (title == null || title.isEmpty) {
        return Error(Exception('Título do documento não pode ser vazio.'));
      }

      final file = getDocumentCommand.value?.tryGetSuccess();
      if (file == null) {
        return Error(
          Exception('Nenhum arquivo de documento disponível para upload.'),
        );
      }

      final request = DocumentUploadRequest(
        titulo: title,
        file: file,
        paciente: nomePaciente,
        medico: nomeMedico,
        tipo: tipoDocumento,
        dataDocumento: dataDocumento,
      );

      uploadDocument.execute(request);

      return Success(null);
    } catch (e) {
      return Error(Exception('Erro ao iniciar o upload do documento: $e'));
    }
  }

  @override
  void dispose() {
    getDocumentCommand.dispose();
    uploadDocument.dispose();
    documentTitle.dispose();
  }
}

class DocumentUploadRequest {
  final String titulo;
  final File file;
  final String? paciente;
  final String? medico;
  final String? tipo;
  final DateTime? dataDocumento;

  DocumentUploadRequest({
    required this.titulo,
    required this.file,
    this.paciente,
    this.medico,
    this.tipo,
    this.dataDocumento,
  }) {
    if (titulo.isEmpty) {
      throw ArgumentError('Título do documento não pode ser vazio.');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DocumentUploadRequest &&
        other.titulo == titulo &&
        other.paciente == paciente &&
        other.medico == medico &&
        other.tipo == tipo &&
        other.dataDocumento == dataDocumento &&
        other.file.path == file.path;
  }

  @override
  int get hashCode {
    return titulo.hashCode ^
        paciente.hashCode ^
        medico.hashCode ^
        tipo.hashCode ^
        dataDocumento.hashCode ^
        file.hashCode;
  }
}

enum DocumentUploadMethod { docScanner, filePicker }

enum UploadStep { preview, labeling, metadata }
