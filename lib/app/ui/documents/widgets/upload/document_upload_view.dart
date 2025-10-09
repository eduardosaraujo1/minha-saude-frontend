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
  final DocumentUploadViewModel _viewModel;
  const DocumentUploadView(this._viewModel, {super.key});

  @override
  State<DocumentUploadView> createState() => _DocumentUploadViewState();
}

class _DocumentUploadViewState extends State<DocumentUploadView> {
  final Logger _logger = Logger('DocumentUploadView');

  late final DocumentUploadViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = widget._viewModel;
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _handleLoadError() {
    _logger.info('Document load cancelled or failed');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Operação cancelada.")));
    context.go(Routes.home);
  }

  void _handleUploadError() {
    _logger.severe('Error uploading document');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Ocorreu um erro ao fazer upload"),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
    context.go(Routes.home);
  }

  void _handleUploadSuccess() {
    _logger.info('Document uploaded successfully');
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        viewModel.loadDocument.results,
        viewModel.uploadDocument.results,
      ]),
      builder: (context, _) {
        final loadCommand = viewModel.loadDocument;
        final uploadCommand = viewModel.uploadDocument;

        // If is loading or no document loaded yet, show loading buffer
        final anyIsExecuting =
            loadCommand.isExecuting.value || uploadCommand.isExecuting.value;
        final hasLoadedDocument = loadCommand.value.tryGetSuccess() != null;
        if (anyIsExecuting || !hasLoadedDocument) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle potential errors after frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (loadCommand.value.isError()) {
            _handleLoadError();
          } else if (uploadCommand.value.isError()) {
            _handleUploadError();
          } else if (uploadCommand.value.isSuccess() &&
              uploadCommand.value.getOrThrow() != null) {
            _handleUploadSuccess();
          }
        });
        if (loadCommand.value.isError() || uploadCommand.value.isError()) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(), //
            ),
          );
        }

        // Happy path: document loaded successfully and upload not in error
        final file = loadCommand.value.getOrThrow()!;

        // Inner ListenableBuilder: Listen to currentStep for navigation
        return ValueListenableBuilder(
          valueListenable: viewModel.currentStep,
          builder: (context, val, _) {
            // Show preview or form based on current step
            return switch (val) {
              UploadStep.preview => DocumentUploadPreview(
                document: PdfDocument.openFile(file.path),
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
