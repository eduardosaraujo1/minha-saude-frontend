part of '../document_upload_navigator.dart';

class UploadPreview extends StatefulWidget {
  const UploadPreview({required this.viewModel, super.key});

  final DocumentUploadViewModel viewModel;

  @override
  State<UploadPreview> createState() => _UploadPreviewState();
}

class _UploadPreviewState extends State<UploadPreview> {
  final ValueNotifier<Result<PdfController, Exception>?> _pdfController =
      ValueNotifier(null);

  DocumentUploadViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    viewModel.getDocumentCommand.addListener(_onGetDocument);
    viewModel.getDocumentCommand.execute();
  }

  @override
  void dispose() {
    viewModel.getDocumentCommand.removeListener(_onGetDocument);
    _pdfController.dispose();
    super.dispose();
  }

  void _onGetDocument() {
    try {
      final result = viewModel.getDocumentCommand.value;

      if (!mounted || result == null) return;

      final file = result.tryGetSuccess();

      if (file == null) {
        // Should not happen, navigator should handle this case
        _pdfController.value = Error(
          Exception(
            'Nenhum arquivo de documento disponível para pré-visualização.',
          ),
        );
        return;
      }

      final pdf = PdfController(document: PdfDocument.openFile(file.path));
      _pdfController.value = Success(pdf);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível carregar a pré-visualização.'),
        ),
      );

      _pdfController.value = Error(
        Exception('Não foi possível carregar a pré-visualização.'),
      );
    }
  }

  void _handleTryAgain() {
    viewModel.getDocumentCommand.execute();
  }

  void _handleConfirm() {
    viewModel.currentStep.value = UploadStep.labeling;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Documento'),
        leading: IconButton(
          key: const Key('btnBack'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.documentos),
        ),
      ),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: viewModel.getDocumentCommand.isExecuting,
      builder: (context, loadingDocument, child) {
        return ValueListenableBuilder(
          valueListenable: _pdfController,
          builder: (context, pdf, child) {
            final isLoading = loadingDocument || pdf == null;

            if (isLoading) {
              return const Center(
                key: Key('loadingIndicator'),
                child: CircularProgressIndicator(),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(
                    builder: (context) {
                      if (pdf.isError()) {
                        return SizedBox.expand(
                          child: Center(
                            child: const Text('Erro ao carregar PDF'),
                          ),
                        );
                      }

                      return _PdfCarousel(
                        key: const Key('pdfCarousel'),
                        pdfController: pdf.tryGetSuccess()!,
                      );
                    },
                  ),
                  _buildBottomCard(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Este documento parece certo?',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          Row(
            spacing: 4,
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  key: const Key('btnCancel'),
                  onPressed: () => _handleTryAgain(),
                  // style: FilledButton.styleFrom(
                  //   padding: const EdgeInsets.symmetric(vertical: 12),
                  //   foregroundColor: colorScheme.onSecondaryContainer,
                  // ),
                  label: const Text('Não'),
                  icon: Icon(
                    Icons.replay,
                    // color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              Expanded(
                child: FilledButton.tonalIcon(
                  key: const Key('btnConfirm'),
                  onPressed: _handleConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    // padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(
                    Icons.check,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  label: const Text('Sim'),
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
  const _PdfCarousel({required this.pdfController, super.key});

  final PdfController pdfController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PdfView(
        controller: pdfController,
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
