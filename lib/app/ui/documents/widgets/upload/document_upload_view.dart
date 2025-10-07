import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    viewModel.loadDocument.addListener(_onCommandChanged);
  }

  @override
  void dispose() {
    viewModel.loadDocument.removeListener(_onCommandChanged);
    viewModel.dispose();
    super.dispose();
  }

  void _onCommandChanged() {
    if (!mounted) return;

    final command = viewModel.loadDocument;
    if (command.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            command.result?.tryGetError()?.toString() ??
                'Erro desconhecido ao carregar documento',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      command.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Documento'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          final status = viewModel.status;
          final errorMessage = viewModel.errorMessage;
          final pdfController = viewModel.pdfController;

          if (status == PageStatus.error && errorMessage != null) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    textAlign: TextAlign.center,
                    errorMessage,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text("Voltar"),
                  ),
                ],
              ),
            );
          } else if (status == PageStatus.loaded && pdfController != null) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [_buildPreview(pdfController), _buildBottomCard()],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildPreview(PdfController pdfController) {
    return Expanded(
      child: PdfView(
        controller: pdfController,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        physics: const BouncingScrollPhysics(),
        onDocumentError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao carregar documento: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBottomCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Este documento parece certo?',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    context.pop();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSecondaryContainer,
                  ),
                  label: const Text('Cancelar'),
                  icon: Icon(
                    Icons.cancel,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    context.go('/documentos/create');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  label: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
