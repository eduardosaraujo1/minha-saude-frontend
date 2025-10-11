import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../routing/routes.dart';

class DocumentUploadPreview extends StatefulWidget {
  const DocumentUploadPreview({
    required this.document,
    required this.onCancel,
    required this.onConfirm,
    super.key,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Future<PdfDocument> document;

  @override
  State<DocumentUploadPreview> createState() => _DocumentUploadPreviewState();
}

class _DocumentUploadPreviewState extends State<DocumentUploadPreview> {
  late final PdfController _pdfController;
  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(document: widget.document);
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Documento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.home),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scanned PDF carousel with pdfx
              _PdfCarousel(pdfController: _pdfController),

              // Text "Está correto?"
              // IconButtons "X Cancelar" and "[checkmark] Confirmar"
              _buildBottomCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCard(BuildContext context) {
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
                  onPressed: widget.onCancel,
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
                  onPressed: widget.onConfirm,
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

class _PdfCarousel extends StatelessWidget {
  const _PdfCarousel({required PdfController pdfController})
    : _pdfController = pdfController;

  final PdfController _pdfController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PdfView(
        controller: _pdfController,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        physics: const BouncingScrollPhysics(),
        onDocumentError: (error) {
          if (context.mounted) {
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
}
