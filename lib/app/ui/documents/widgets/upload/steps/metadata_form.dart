part of '../document_upload_navigator.dart';

class MetadataForm extends StatefulWidget {
  const MetadataForm({required this.viewModel, super.key});

  final DocumentUploadViewModel viewModel;

  @override
  State<MetadataForm> createState() => _MetadataFormState();
}

class _MetadataFormState extends State<MetadataForm> {
  final MetadataFormController controller = MetadataFormController();
  DocumentUploadViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _triggerDocumentDatePicker(BuildContext context) async {
    final dataDocumentoController = controller.dataDocumentoController;

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

  void _submitForm() {
    if (!controller.validate()) {
      return;
    }

    DateTime? dataDocumento;
    if (controller.dataDocumentoController.text.isNotEmpty) {
      final dateResult = parseDateString(
        controller.dataDocumentoController.text,
      );
      if (dateResult.isError()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ocorreu um erro ao processar a data do documento. Tente selecioná-la novamente.',
            ),
          ),
        );
        return;
      }
      dataDocumento = dateResult.tryGetSuccess();
    }

    final result = viewModel.triggerUploadWithMetadata(
      nomePaciente: controller.nomePacienteController.text.isEmpty
          ? null
          : controller.nomePacienteController.text,
      nomeMedico: controller.nomeMedicoController.text.isEmpty
          ? null
          : controller.nomeMedicoController.text,
      tipoDocumento: controller.tipoDocumentoController.text.isEmpty
          ? null
          : controller.tipoDocumentoController.text,
      dataDocumento: dataDocumento,
    );

    if (result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.tryGetError()?.toString() ?? 'Erro ao enviar documento',
          ),
        ),
      );
    }
  }

  void _skipForm() {
    final result = viewModel.triggerUploadWithMetadata(
      nomePaciente: null,
      nomeMedico: null,
      tipoDocumento: null,
      dataDocumento: null,
    );

    if (result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.tryGetError()?.toString() ?? 'Erro ao enviar documento',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        key: const Key('appBar'),
        title: const Text('Adicionar Documento'),
        leading: IconButton(
          key: const Key('btnBack'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            viewModel.currentStep.value = UploadStep.labeling;
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Text(
                  'Vamos organizar o seu documento',
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  'Informe os dados abaixo para facilitar a localização do arquivo',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('inputNomePaciente'),
                  controller: controller.nomePacienteController,
                  validator: controller.validateNomePaciente,
                  decoration: const InputDecoration(
                    labelText: 'Nome do(a) paciente',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  key: const Key('inputNomeMedico'),
                  controller: controller.nomeMedicoController,
                  validator: controller.validateNomeMedico,
                  decoration: const InputDecoration(
                    labelText: 'Nome do(a) médico(a)',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  key: const Key('inputTipoDocumento'),
                  controller: controller.tipoDocumentoController,
                  validator: controller.validateTipoDocumento,
                  decoration: const InputDecoration(
                    labelText: 'Tipo do documento',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  key: const Key('inputDataDocumento'),
                  controller: controller.dataDocumentoController,
                  validator: controller.validateDataDocumento,
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
                ValueListenableBuilder(
                  valueListenable: viewModel.uploadDocument.isExecuting,
                  builder: (context, isExecuting, child) {
                    return Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            key: const Key('btnSkip'),
                            onPressed: isExecuting ? null : _skipForm,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Pular essa etapa'),
                          ),
                        ),
                        Expanded(
                          child: FilledButton(
                            key: const Key('btnSubmit'),
                            onPressed: isExecuting ? null : _submitForm,
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: isExecuting
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : const Text('Salvar e Continuar'),
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
      ),
    );
  }
}

class MetadataFormController {
  final formKey = GlobalKey<FormState>();
  final nomePacienteController = TextEditingController();
  final nomeMedicoController = TextEditingController();
  final tipoDocumentoController = TextEditingController();
  final dataDocumentoController = TextEditingController();

  /// Validates the form and returns true if valid
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateNomePaciente(String? value) {
    // Optional field, no validation needed
    return null;
  }

  String? validateNomeMedico(String? value) {
    // Optional field, no validation needed
    return null;
  }

  String? validateTipoDocumento(String? value) {
    // Optional field, no validation needed
    return null;
  }

  String? validateDataDocumento(String? value) {
    // Optional field, no validation needed
    return null;
  }

  void dispose() {
    nomePacienteController.dispose();
    nomeMedicoController.dispose();
    tipoDocumentoController.dispose();
    dataDocumentoController.dispose();
  }
}
