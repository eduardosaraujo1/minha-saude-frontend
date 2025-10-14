import 'package:flutter/material.dart';

/// ViewModel for document info form.
/// This ViewModel only manages form validation and data.
/// The actual upload is handled by the parent DocumentUploadViewModel.
class DocumentInfoFormViewModel {
  DocumentInfoFormViewModel({required this.onFormSubmit});

  final void Function(DocumentFormData) onFormSubmit;
  final form = DocumentFormController();

  void submitForm() {
    if (form.validate()) {
      final formData = form.getFormData();
      onFormSubmit(formData);
    }
  }

  void dispose() {
    form.dispose();
  }
}

/// Data class to hold form data
class DocumentFormData {
  final String titulo;
  final String? nomePaciente;
  final String? nomeMedico;
  final String? tipoDocumento;
  final DateTime? dataDocumento;

  DocumentFormData({
    required this.titulo,
    this.nomePaciente,
    this.nomeMedico,
    this.tipoDocumento,
    this.dataDocumento,
  });
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

  /// Get form data as a DocumentFormData object
  DocumentFormData getFormData() {
    // Parse date from dd/MM/yyyy format
    DateTime? parsedDate;
    final dateText = dataDocumentoController.text;
    if (dateText.isNotEmpty) {
      try {
        final parts = dateText.split('/');
        if (parts.length == 3) {
          parsedDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (_) {
        // If parsing fails, leave as null
      }
    }

    return DocumentFormData(
      titulo: tituloController.text,
      nomePaciente: nomePacienteController.text.isEmpty
          ? null
          : nomePacienteController.text,
      nomeMedico: nomeMedicoController.text.isEmpty
          ? null
          : nomeMedicoController.text,
      tipoDocumento: tipoDocumentoController.text.isEmpty
          ? null
          : tipoDocumentoController.text,
      dataDocumento: parsedDate,
    );
  }

  void dispose() {
    tituloController.dispose();
    nomePacienteController.dispose();
    nomeMedicoController.dispose();
    tipoDocumentoController.dispose();
    dataDocumentoController.dispose();
  }
}
