import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/metadata/document_edit_view_model.dart';

class DocumentEditScreen extends StatefulWidget {
  const DocumentEditScreen(this.viewModelFactory, {super.key});

  final DocumentEditViewModel Function() viewModelFactory;

  @override
  State<DocumentEditScreen> createState() => _DocumentEditScreenState();
}

class _DocumentEditScreenState extends State<DocumentEditScreen> {
  late final DocumentEditViewModel viewModel = widget.viewModelFactory();

  @override
  void initState() {
    super.initState();
    viewModel.updateDocument.addListener(_onUpdateCommand);
    viewModel.loadDocument.execute();
  }

  @override
  void dispose() {
    viewModel.updateDocument.removeListener(_onUpdateCommand);
    super.dispose();
  }

  void triggerUpdateIfValid() {
    if (viewModel.form.validate()) {
      viewModel.updateDocument.execute();
    }
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

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: viewModel.form.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    TextFormField(
                      key: const ValueKey('tituloField'),
                      controller: viewModel.form.titulo,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: viewModel.form.validateTitulo,
                    ),
                    TextFormField(
                      key: const ValueKey('pacienteField'),
                      controller: viewModel.form.paciente,
                      decoration: const InputDecoration(
                        labelText: 'Paciente',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: viewModel.form.validatePaciente,
                    ),
                    TextFormField(
                      key: const ValueKey('medicoField'),
                      controller: viewModel.form.medico,
                      decoration: const InputDecoration(
                        labelText: 'Médico',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: viewModel.form.validateMedico,
                    ),
                    TextFormField(
                      key: const ValueKey('tipoField'),
                      controller: viewModel.form.tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Documento',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: viewModel.form.validateTipo,
                    ),
                    TextFormField(
                      key: const ValueKey("dataDocumentoField"),
                      controller: viewModel.form.dataDocumento,
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
                                    : triggerUpdateIfValid,
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
    final controller = viewModel.form.dataDocumento;

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
