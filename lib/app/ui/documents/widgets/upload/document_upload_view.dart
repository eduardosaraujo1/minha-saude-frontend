import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/routing/routes.dart';
import 'package:minha_saude_frontend/app/ui/documents/widgets/upload/document_upload_preview.dart';
import 'package:pdfx/pdfx.dart';

import '../../view_models/upload/document_upload_view_model.dart';

class DocumentUploadView extends StatefulWidget {
  final DocumentUploadViewModel viewModel;
  const DocumentUploadView(this.viewModel, {super.key});

  @override
  State<DocumentUploadView> createState() => _DocumentUploadViewState();
}

class _DocumentUploadViewState extends State<DocumentUploadView> {
  DocumentUploadViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    // viewModel.loadDocument.addListener(_onCommandChanged);
  }

  @override
  void dispose() {
    // viewModel.loadDocument.removeListener(_onCommandChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel.loadDocument,
      builder: (context, _) {
        if (viewModel.loadDocument.isExecuting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.uploadedFile == null) {
          return Center(
            child: Text(
              'Nenhum documento carregado.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return DocumentUploadPreview(
          document: PdfDocument.openFile(viewModel.uploadedFile!.path),
          onCancel: () {
            context.go(Routes.home);
          },
          onConfirm: () {
            // VIEWMODEL: NAVIGATE TO NEXT STEP (DocumentInfoFOrm)
          },
        );
      },
    );
  }
}
