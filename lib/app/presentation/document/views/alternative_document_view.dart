import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_view_model.dart';
import 'package:watch_it/watch_it.dart';

/// Alternative PDF viewer using WebView (fallback option)
class AlternativeDocumentView extends WatchingWidget {
  final DocumentViewModel viewModel;
  const AlternativeDocumentView(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final document = watch(viewModel.document).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(document?.titulo ?? 'Visualizar Documento'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh the view
              // You can implement state refresh here
            },
          ),
        ],
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
          : FutureBuilder<Uint8List>(
              future: _loadPdfBytes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Carregando PDF...'),
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
                          'Erro ao carregar PDF',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Retry loading - rebuild the widget
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AlternativeDocumentView(viewModel),
                              ),
                            );
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final pdfBytes = snapshot.data!;
                return _buildPdfPreview(context, document, pdfBytes);
              },
            ),
    );
  }

  Widget _buildPdfPreview(
    BuildContext context,
    dynamic document,
    Uint8List pdfBytes,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document info header
          if (document.titulo?.isNotEmpty == true) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.titulo,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tamanho: ${(pdfBytes.length / 1024).toStringAsFixed(1)} KB',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // PDF Content Area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // PDF Toolbar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text(
                          'Documento PDF',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _openPdfExternally(context, pdfBytes),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Abrir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // PDF Preview Area
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Visualização do PDF',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Clique em "Abrir" para visualizar o documento completo',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _loadPdfBytes() async {
    try {
      final byteData = await rootBundle.load('assets/fake/document.pdf');
      return byteData.buffer.asUint8List();
    } catch (e) {
      throw Exception('Failed to load PDF: $e');
    }
  }

  void _openPdfExternally(BuildContext context, Uint8List pdfBytes) {
    // TODO: Implement external PDF opening
    // You could save the file to device and open with system PDF viewer
    // or implement a more sophisticated PDF viewer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de abertura externa em desenvolvimento'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
