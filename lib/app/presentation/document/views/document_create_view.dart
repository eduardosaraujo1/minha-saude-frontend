import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_create_view_model.dart';
import 'package:watch_it/watch_it.dart';

class DocumentCreateView extends WatchingStatefulWidget {
  final DocumentCreateViewModel viewModel;

  const DocumentCreateView(this.viewModel, {super.key});

  @override
  State<DocumentCreateView> createState() => _DocumentCreateViewState();
}

class _DocumentCreateViewState extends State<DocumentCreateView> {
  DocumentCreateViewModel get viewModel => widget.viewModel;

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
        title: const Text('Criar Documento'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
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
                        context.go('/');
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Pular essa etapa'),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (form.validate()) {
                          context.go('/');
                        }
                      },
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
