import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../utils/format.dart';
import '../../view_models/metadata/document_edit_view_model.dart';

class DocumentEditScreen extends StatefulWidget {
  const DocumentEditScreen(this.viewModelFactory, {super.key});

  final DocumentEditViewModel Function() viewModelFactory;

  @override
  State<DocumentEditScreen> createState() => _DocumentEditScreenState();
}

class _DocumentEditScreenState extends State<DocumentEditScreen> {
  late final DocumentEditViewModel viewModel = widget.viewModelFactory();
  late final DocumentFormController formController = DocumentFormController();

  @override
  void initState() {
    super.initState();
    viewModel.updateDocument.addListener(_onUpdateCommand);
    viewModel.loadDocument.execute();
  }

  @override
  void dispose() {
    formController.dispose();
    viewModel.updateDocument.removeListener(_onUpdateCommand);
    super.dispose();
  }

  void _onUpdateCommand() {
    if (!mounted) return;
    if (viewModel.updateDocument.value == null) {
      // Initial state
      return;
    }

    if (viewModel.updateDocument.value!.isError()) {
      final error = viewModel.updateDocument.value!.tryGetError()!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      // Success - go back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Documento atualizado com sucesso!')),
      );
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Documento')),
      body: ValueListenableBuilder(
        valueListenable: viewModel.loadDocument.isExecuting,
        builder: (context, isLoading, child) {
          if (isLoading || viewModel.loadDocument.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.loadDocument.value!.isError()) {
            final error = viewModel.loadDocument.value!.tryGetError()!;
            return Center(
              child: Text(
                'Erro ao carregar documento: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          // Populate form fields
          final document = viewModel.loadDocument.value!.tryGetSuccess()!;

          formController.titulo.text = document.titulo;

          if (document.dataDocumento != null) {
            formController.dataDocumento.text = formatDate(
              document.dataDocumento!,
            );
          }
          if (document.medico != null) {
            formController.medico.text = document.medico!;
          }
          if (document.paciente != null) {
            formController.paciente.text = document.paciente!;
          }
          if (document.tipo != null) {
            formController.tipo.text = document.tipo!;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formController.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    TextFormField(
                      key: const ValueKey('tituloField'),
                      controller: formController.titulo,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: formController.validateTitulo,
                    ),
                    TextFormField(
                      key: const ValueKey('pacienteField'),
                      controller: formController.paciente,
                      decoration: const InputDecoration(
                        labelText: 'Paciente',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: formController.validatePaciente,
                    ),
                    TextFormField(
                      key: const ValueKey('medicoField'),
                      controller: formController.medico,
                      decoration: const InputDecoration(
                        labelText: 'Médico',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: formController.validateMedico,
                    ),
                    TextFormField(
                      key: const ValueKey('tipoField'),
                      controller: formController.tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Documento',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: formController.validateTipo,
                    ),
                    TextFormField(
                      key: const ValueKey("dataDocumentoField"),
                      controller: formController.dataDocumento,
                      decoration: const InputDecoration(
                        labelText: 'Data do Documento',
                        suffixIcon: Icon(Icons.calendar_today),
                        counterText: '',
                      ),
                      readOnly: true,
                      onTap: () => _triggerDocDatePicker(context),
                    ),
                    ValueListenableBuilder(
                      valueListenable: viewModel.updateDocument.isExecuting,
                      builder: (context, updatingDoc, child) {
                        return Row(
                          spacing: 4,
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                key: const ValueKey('cancelButton'),
                                onPressed: updatingDoc
                                    ? null
                                    : () {
                                        context.pop();
                                      },
                                child: const Text('Cancelar'),
                              ),
                            ),
                            Expanded(
                              child: FilledButton(
                                key: const ValueKey("saveButton"),
                                onPressed: updatingDoc
                                    ? null
                                    : () {
                                        if (formController.validate()) {
                                          final formData =
                                              formController.formData;
                                          viewModel.updateDocument.execute(
                                            formData,
                                          );
                                        }
                                      },
                                child: const Text('Salvar'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _triggerDocDatePicker(BuildContext context) async {
    final controller = formController.dataDocumento;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      controller.value = TextEditingValue(
        text: "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
      );
    }
  }
}

class DocumentFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titulo = TextEditingController();
  final TextEditingController paciente = TextEditingController();
  final TextEditingController medico = TextEditingController();
  final TextEditingController tipo = TextEditingController();
  final TextEditingController dataDocumento = TextEditingController();

  DocumentUploadModel get formData => DocumentUploadModel(
    titulo: titulo.text,
    paciente: paciente.text.isEmpty ? null : paciente.text,
    medico: medico.text.isEmpty ? null : medico.text,
    tipo: tipo.text.isEmpty ? null : tipo.text,
    dataDocumento: dataDocumento.text.isEmpty
        ? null
        : _parseDate(dataDocumento.text),
  );

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateTitulo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o título do documento.';
    }

    if (value.length > 100) {
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

  void dispose() {
    titulo.dispose();
    paciente.dispose();
    medico.dispose();
    tipo.dispose();
    dataDocumento.dispose();
  }
}
