import 'package:flutter/material.dart';

import '../../view_models/upload/document_info_form_model.dart';

class DocumentInfoFormView extends StatefulWidget {
  final DocumentInfoFormViewModel viewModel;
  final VoidCallback onBack;

  const DocumentInfoFormView(this.viewModel, {required this.onBack, super.key});

  @override
  State<DocumentInfoFormView> createState() => _DocumentCreateViewState();
}

class _DocumentCreateViewState extends State<DocumentInfoFormView> {
  late final DocumentInfoFormViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModel;
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = viewModel.form;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Documento'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: form.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                "Vamos organizar o seu documento",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                "Informe os dados abaixo para facilitar a localização do arquivo",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: form.tituloController,
                validator: form.validateTitulo,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: form.nomePacienteController,
                validator: form.validateNomePaciente,
                decoration: const InputDecoration(
                  labelText: 'Nome do(a) paciente',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: form.nomeMedicoController,
                validator: form.validateNomeMedico,
                decoration: const InputDecoration(
                  labelText: 'Nome do(a) médico(a)',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: form.tipoDocumentoController,
                validator: form.validateTipoDocumento,
                decoration: const InputDecoration(
                  labelText: 'Tipo do documento',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: form.dataDocumentoController,
                validator: form.validateDataDocumento,
                decoration: const InputDecoration(
                  labelText: 'Data do documento',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () => _triggerDocumentDatePicker(context),
              ),
              const SizedBox(height: 8),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {
                        // Skip form and submit with only required fields
                        viewModel.onFormSubmit(
                          DocumentFormData(titulo: 'Documento sem título'),
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Pular essa etapa'),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: viewModel.submitForm,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Salvar e Continuar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerDocumentDatePicker(BuildContext context) async {
    final dataDocumentoController = viewModel.form.dataDocumentoController;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      dataDocumentoController.value = TextEditingValue(
        text: "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
      );
    }
  }
}
