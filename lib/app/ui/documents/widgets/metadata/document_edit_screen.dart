import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/metadata/document_edit_view_model.dart';

class DocumentEditScreen extends StatelessWidget {
  const DocumentEditScreen(this.viewModel, {super.key});

  final DocumentEditViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Warning: the below command should NOT be inside a ListenableBuilder. If you make
    // this a stateful widget, you should move this to initState.
    viewModel.loadDocument.execute();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Documento'),
        backgroundColor: colorScheme.surfaceContainer,
      ),
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
                                    : () {
                                        viewModel.updateDocument.execute();
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
