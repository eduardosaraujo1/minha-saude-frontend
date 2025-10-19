part of '../document_upload_navigator.dart';

class TitleForm extends StatelessWidget {
  const TitleForm({required this.viewModel, super.key});

  final DocumentUploadViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = TextEditingController(
      text: viewModel.documentTitle.value,
    );
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        key: const Key('appBar'),
        title: const Text('Adicionar Documento'),
        leading: IconButton(
          key: const Key('btnBack'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            viewModel.currentStep.value = UploadStep.preview;
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              Text(
                'Dê um título ao documento',
                style: theme.textTheme.titleLarge,
              ),
              Text(
                'Isso ajudará a identificar o documento mais tarde',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Form(
                key: formKey,
                child: TextFormField(
                  key: const Key('inputTitle'),
                  controller: titleController,
                  validator: _validateTitle,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    counterText: "",
                  ),
                  maxLength: 100,
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                key: const Key('btnNext'),
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  viewModel.documentTitle.value = titleController.text.trim();
                  viewModel.currentStep.value = UploadStep.metadata;
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Próximo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateTitle(String? value) {
    final title = value?.trim();

    if (title == null || title.isEmpty) {
      return 'Por favor, insira um título';
    }

    return null;
  }
}
