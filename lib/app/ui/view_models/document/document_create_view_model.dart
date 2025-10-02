import 'package:flutter/material.dart';

// TODO: implement with DocumentRepository real creation
class DocumentCreateViewModel {
  final state = ValueNotifier<PageStatus>(PageStatus.initial);
  final errorMessage = ValueNotifier<String?>(null);
  final form = DocumentFormController();

  void dispose() {
    // state.dispose();
    // errorMessage.dispose();
    form.dispose();
  }
}

class DocumentFormController {
  final formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final nomePacienteController = TextEditingController();
  final nomeMedicoController = TextEditingController();
  final tipoDocumentoController = TextEditingController();
  final dataDocumentoController = TextEditingController();

  /// Validates the form and returns true if valid
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateTitulo(String? value) {
    if (value != null && value.length > 100) {
      return 'O título não pode exceder 100 caracteres';
    }
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o título do documento';
    }
    return null;
  }

  String? validateNomePaciente(String? value) {
    if (value != null && value.length > 100) {
      return 'O nome do paciente não pode exceder 100 caracteres';
    }
    return null;
  }

  String? validateNomeMedico(String? value) {
    if (value != null && value.length > 100) {
      return 'O nome do médico não pode exceder 100 caracteres';
    }
    return null;
  }

  String? validateTipoDocumento(String? value) {
    if (value != null && value.length > 100) {
      return 'O tipo do documento não pode exceder 100 caracteres';
    }
    return null;
  }

  String? validateDataDocumento(String? value) {
    if (value != null && value.length > 100) {
      return 'A data do documento não pode exceder 100 caracteres';
    }
    return null;
  }

  void dispose() {
    tituloController.dispose();
    nomePacienteController.dispose();
    nomeMedicoController.dispose();
    tipoDocumentoController.dispose();
    dataDocumentoController.dispose();
  }
}

enum PageStatus { initial, loading, loaded, error }
