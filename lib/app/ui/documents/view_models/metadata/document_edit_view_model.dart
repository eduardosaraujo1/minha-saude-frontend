import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../data/repositories/document/document_repository.dart';
import '../../../../domain/models/document/document.dart';

class DocumentEditViewModel {
  DocumentEditViewModel({
    required this.documentUuid,
    required this.documentRepository,
  }) {
    loadDocument = Command.createAsyncNoParam<Result<Document, Exception>?>(
      _loadDocument,
      initialValue: null,
    );
    updateDocument = Command.createAsyncNoParam<Result<Document, Exception>?>(
      _updateDocument,
      initialValue: null,
    );
  }

  final String documentUuid;
  final DocumentRepository documentRepository;
  final DocumentEditForm _form = DocumentEditForm();
  final Logger _log = Logger('document_edit_view_model');

  late final Command<void, Result<Document, Exception>?> loadDocument;
  late final Command<void, Result<Document, Exception>?> updateDocument;

  DocumentEditForm get form => _form;

  Future<Result<Document, Exception>> _loadDocument() async {
    try {
      final document = await documentRepository.getDocumentMeta(documentUuid);

      // Load command
      if (document.isError()) {
        final error = document.tryGetError()!;
        _log.severe("Error loading document: $error");
        return Result.error(Exception("Erro ao carregar documento."));
      }

      // Populate form fields
      _form.titulo.text = document.tryGetSuccess()!.titulo!;
      _form.dataDocumento.text = DateFormat(
        'dd/MM/yyyy',
      ).format(document.tryGetSuccess()!.dataDocumento!);
      _form.medico.text = document.tryGetSuccess()!.medico!;
      _form.paciente.text = document.tryGetSuccess()!.paciente!;
      _form.tipo.text = document.tryGetSuccess()!.tipo!;

      return Result.success(document.tryGetSuccess()!);
    } catch (e, s) {
      _log.severe("Failed to load document", e, s);
      return Result.error(Exception("Erro ao carregar documento."));
    }
  }

  Future<Result<Document, Exception>> _updateDocument() async {
    try {
      // Get form values
      final titulo = _form.titulo.text;
      final dataDocumento = DateFormat(
        'dd/MM/yyyy',
      ).tryParse(_form.dataDocumento.text);
      final medico = _form.medico.text;
      final paciente = _form.paciente.text;
      final tipo = _form.tipo.text;

      final result = await documentRepository.updateDocument(
        documentUuid,
        titulo: titulo,
        dataDocumento: dataDocumento,
        medico: medico,
        paciente: paciente,
        tipo: tipo,
      );

      if (result.isError()) {
        final error = result.tryGetError()!;
        _log.severe("Error updating document: $error");
        return Result.error(Exception("Erro ao atualizar documento."));
      }

      return Result.success(result.tryGetSuccess()!);
    } catch (e, s) {
      _log.severe("Failed to update document", e, s);
      return Result.error(Exception("Erro ao atualizar documento."));
    }
  }
}

class DocumentEditForm {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titulo = TextEditingController();
  final TextEditingController paciente = TextEditingController();
  final TextEditingController medico = TextEditingController();
  final TextEditingController tipo = TextEditingController();
  final TextEditingController dataDocumento = TextEditingController();

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateTitulo(String? value) {
    if (value != null && value.length > 100) {
      return 'O título não pode ter mais de 100 caracteres.';
    }
    return null;
  }

  String? validatePaciente(String? value) {
    if (value != null && value.length > 100) {
      return 'O nome do paciente não pode ter mais de 100 caracteres.';
    }
    return null;
  }

  String? validateMedico(String? value) {
    if (value != null && value.length > 100) {
      return 'O nome do médico não pode ter mais de 100 caracteres.';
    }
    return null;
  }

  String? validateTipo(String? value) {
    if (value != null && value.length > 50) {
      return 'O tipo não pode ter mais de 50 caracteres.';
    }
    return null;
  }

  String? validateDataDocumento(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira a data do documento.';
    }

    try {
      _parseDate(value);
    } catch (e) {
      return 'Data do documento inválida. Use o formato DD/MM/AAAA.';
    }

    return null;
  }

  DateTime _parseDate(String value) {
    return DateFormat('dd/MM/yyyy').parseStrict(value);
  }
}
