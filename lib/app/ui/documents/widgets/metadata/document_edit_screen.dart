import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/metadata/document_edit_view_model.dart';

class DocumentEditScreen extends StatefulWidget {
  const DocumentEditScreen(this.viewModel, {super.key});

  final DocumentEditViewModel viewModel;

  @override
  State<DocumentEditScreen> createState() => _DocumentEditScreenState();
}

class _DocumentEditScreenState extends State<DocumentEditScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.updateDocument.addListener(_onUpdateCommand);
  }

  @override
  void didUpdateWidget(DocumentEditScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.updateDocument.removeListener(_onUpdateCommand);
      widget.viewModel.updateDocument.addListener(_onUpdateCommand);
    }
  }

  @override
  void dispose() {
    widget.viewModel.updateDocument.removeListener(_onUpdateCommand);
    super.dispose();
  }

  void triggerUpdateIfValid() {
    if (widget.viewModel.form.validate()) {
      widget.viewModel.updateDocument.execute();
    }
  }

  void _onUpdateCommand() {
    if (!mounted) return;
    if (widget.viewModel.updateDocument.value == null) {
      // Initial state
      return;
    }

    if (widget.viewModel.updateDocument.value!.isError()) {
      final error = widget.viewModel.updateDocument.value!.tryGetError()!;

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
        valueListenable: widget.viewModel.loadDocument.isExecuting,
        builder: (context, isLoading, child) {
          if (isLoading || widget.viewModel.loadDocument.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: widget.viewModel.form.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    TextFormField(
                      key: const ValueKey('tituloField'),
                      controller: widget.viewModel.form.titulo,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: widget.viewModel.form.validateTitulo,
                    ),
                    TextFormField(
                      key: const ValueKey('pacienteField'),
                      controller: widget.viewModel.form.paciente,
                      decoration: const InputDecoration(
                        labelText: 'Paciente',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: widget.viewModel.form.validatePaciente,
                    ),
                    TextFormField(
                      key: const ValueKey('medicoField'),
                      controller: widget.viewModel.form.medico,
                      decoration: const InputDecoration(
                        labelText: 'Médico',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: widget.viewModel.form.validateMedico,
                    ),
                    TextFormField(
                      key: const ValueKey('tipoField'),
                      controller: widget.viewModel.form.tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Documento',
                        counterText: '',
                      ),
                      maxLength: 100,
                      validator: widget.viewModel.form.validateTipo,
                    ),
                    TextFormField(
                      key: const ValueKey("dataDocumentoField"),
                      controller: widget.viewModel.form.dataDocumento,
                      decoration: const InputDecoration(
                        labelText: 'Data do Documento',
                        suffixIcon: Icon(Icons.calendar_today),
                        counterText: '',
                      ),
                      readOnly: true,
                      onTap: () => _triggerDocDatePicker(context),
                    ),
                    ValueListenableBuilder(
                      valueListenable:
                          widget.viewModel.updateDocument.isExecuting,
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
    final controller = widget.viewModel.form.dataDocumento;

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
