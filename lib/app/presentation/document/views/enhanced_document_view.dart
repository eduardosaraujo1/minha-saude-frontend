import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_view_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watch_it/watch_it.dart';

/// Enhanced PDF viewer that can handle both asset and network PDFs
class EnhancedDocumentView extends WatchingWidget {
  final DocumentViewModel viewModel;
  const EnhancedDocumentView(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final document = watch(viewModel.document).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(document?.titulo ?? 'Visualizar Documento'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [
          if (document != null) ...[
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // TODO: Implement download functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download em desenvolvimento')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Compartilhar em desenvolvimento'),
                  ),
                );
              },
            ),
          ],
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
          : FutureBuilder<String>(
              future: _getPdfPath(),
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
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Voltar'),
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
                    if (document.descricao?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        document.descricao,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // PDF Viewer
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PDFView(
                  filePath: pdfPath,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation: false,
                  onRender: (pages) {
                    debugPrint('PDF rendered with $pages pages');
                  },
                  onError: (error) {
                    debugPrint('PDF Error: $error');
                  },
                  onViewCreated: (PDFViewController controller) {
                    debugPrint('PDF View Created');
                  },
                  onPageChanged: (int? page, int? total) {
                    debugPrint('Page changed: $page/$total');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gets the PDF path - handles both assets and network files
  Future<String> _getPdfPath() async {
    // For now, just return the asset path
    // You can extend this to handle network downloads or local files
    return await _getAssetPdfPath('assets/fake/document.pdf');
  }

  /// Copies asset PDF to temporary directory for PDFView to access
  Future<String> _getAssetPdfPath(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final file = File(
        '${(await getTemporaryDirectory()).path}/temp_document.pdf',
      );
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (e) {
      throw Exception('Failed to load PDF from assets: $e');
    }
  }

  /// Downloads PDF from network (for future use)
  // Future<String> _downloadPdf(String url) async {
  //   try {
  //     // TODO: Implement network PDF download
  //     // You could use Dio or http package to download the file
  //     throw UnimplementedError('Network PDF download not yet implemented');
  //   } catch (e) {
  //     throw Exception('Failed to download PDF: $e');
  //   }
  // }
}
