import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/routing/routes.dart';
import 'package:minha_saude_frontend/app/ui/documents/widgets/upload/document_upload_preview.dart';
import 'package:pdfx/pdfx.dart';

import '../../view_models/upload/document_info_form_model.dart';
import '../../view_models/upload/document_upload_view_model.dart';
import 'document_info_form.dart';

class DocumentUploadView extends StatefulWidget {
  final DocumentUploadViewModel viewModel;
  const DocumentUploadView(this.viewModel, {super.key});

  @override
  State<DocumentUploadView> createState() => _DocumentUploadViewState();
}

class _DocumentUploadViewState extends State<DocumentUploadView> {
  final Logger _logger = Logger('DocumentUploadView');

  DocumentUploadViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.loadDocument.addListener(_onLoadCommandChanged);
    viewModel.uploadDocument.addListener(_onUploadCommandChanged);
  }

  @override
  void dispose() {
    viewModel.loadDocument.removeListener(_onLoadCommandChanged);
    viewModel.uploadDocument.removeListener(_onUploadCommandChanged);
    viewModel.dispose();
    super.dispose();
  }

  void _onLoadCommandChanged() {
    if (!mounted) return;

    final loadCommand = viewModel.loadDocument;

    // If load fails (e.g., scan cancelled), show message and go home
    if (loadCommand.isError) {
      _logger.info(
        'Document load cancelled or failed',
        loadCommand.result?.tryGetError(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Operação cancelada.")));
      loadCommand.clearResult();
      context.go(Routes.home);
    }
  }

  void _onUploadCommandChanged() {
    if (!mounted) return;

    final uploadCommand = viewModel.uploadDocument;

    if (uploadCommand.isError) {
      // Show error message and go home
      final error = uploadCommand.result?.tryGetError();
      _logger.severe('Error uploading document: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Ocorreu um erro ao fazer upload"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      uploadCommand.clearResult();
      context.go(Routes.home);
    } else if (uploadCommand.isSuccess) {
      // Upload successful, go home
      _logger.info('Document uploaded successfully');
      uploadCommand.clearResult();
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Outer ListenableBuilder: Listen to commands for loading/error states
    return ListenableBuilder(
      listenable: Listenable.merge([
        viewModel.loadDocument,
        viewModel.uploadDocument,
      ]),
      builder: (context, _) {
        // Show loading while loading document or uploading
        if (viewModel.loadDocument.isExecuting ||
            viewModel.uploadDocument.isExecuting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.uploadedFile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Adicionar Documento')),
            body: Center(
              child: Text(
                'Nenhum documento carregado.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        // Inner ListenableBuilder: Listen to currentStep for navigation
        return ListenableBuilder(
          listenable: viewModel.currentStep,
          builder: (context, _) {
            // Show preview or form based on current step
            return switch (viewModel.currentStep.value) {
              UploadStep.preview => DocumentUploadPreview(
                document: PdfDocument.openFile(viewModel.uploadedFile!.path),
                onCancel: () => context.go(Routes.home),
                onConfirm: viewModel.goToForm,
              ),
              UploadStep.form => DocumentInfoFormView(
                DocumentInfoFormViewModel(
                  onFormSubmit: viewModel.handleFormSubmit,
                ),
                onBack: viewModel.goBackToPreview,
              ),
            };
          },
        );
      },
    );
  }
}
