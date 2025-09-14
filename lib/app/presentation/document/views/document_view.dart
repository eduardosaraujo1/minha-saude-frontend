import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_view_model.dart';
import 'package:watch_it/watch_it.dart';

class DocumentView extends WatchingWidget {
  final DocumentViewModel viewModel;
  const DocumentView(this.viewModel, {super.key});

  void _onErrorChanged(BuildContext context, String? newValue) {
    if (newValue != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(newValue)));
      viewModel.errorMessage.value = null; // Reset after showing
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = watch(viewModel.document).value;

    registerHandler<ValueNotifier, String?>(
      target: viewModel.errorMessage,
      handler: (context, newValue, cancel) {
        _onErrorChanged(context, newValue);
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(document?.titulo ?? 'Visualizar Documento'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: document == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando documento...'),
                ],
              ),
            )
          : FutureBuilder<String>(
              future: viewModel.pdfPathFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Preparando documento...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar documento',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final pdfPath = snapshot.data!;
                return _buildPdfView(context, document, pdfPath);
              },
            ),
    );
  }

  Widget _buildPdfView(BuildContext context, dynamic document, String pdfPath) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PDFView(
              filePath: pdfPath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              fitEachPage: true,
              pageFling: true,
              pageSnap: true,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              backgroundColor: Theme.of(context).colorScheme.surfaceBright,
              onError: (error) {
                viewModel.errorMessage.value = error.toString();
              },
              onViewCreated: (PDFViewController controller) {
                debugPrint('PDF View Created');
              },
            ),
          ),
        ],
      ),
    );
  }
}
