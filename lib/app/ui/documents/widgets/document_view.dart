import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart';

import '../../../routing/routes.dart';
import '../view_models/document_view_model.dart';
import '../../core/widgets/document_pdf_viewer.dart';
import 'page_indicator.dart';

class DocumentView extends StatefulWidget {
  const DocumentView(this.viewModel, {super.key});

  final DocumentViewModel viewModel;

  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  DocumentViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    viewModel.loadDocument.results.addListener(_rebuild);
    viewModel.deleteDocument.addListener(_handleDeleteDocument);
  }

  @override
  void dispose() {
    viewModel.loadDocument.results.removeListener(_rebuild);

    super.dispose();
  }

  void _rebuild() {
    setState(() {});
  }

  void _handleDeleteDocument() {
    final command = viewModel.deleteDocument;

    if (command.isExecuting.value || command.value == null) {
      return; // Still executing or no result yet
    }

    // Show snackbar with success or error message
    if (command.value!.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ocorreu um erro desconhecido ao excluir o documento."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Documento movido para a lixeira.")),
      );
    }

    // Navigate back to home or previous screen
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final loadDocResult = viewModel.loadDocument.results.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Documento'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [
          if (loadDocResult.hasData && loadDocResult.data != null) ...[
            _DocumentActionsMenu((DocumentAction action) {
              if (action == DocumentAction.view) {
                // Show info
              } else if (action == DocumentAction.edit) {
                // Edit document
              } else if (action == DocumentAction.delete) {
                // Delete document
                showDialog(
                  context: context,
                  builder: (context) {
                    return _DeleteDocumentDialog(
                      document: loadDocResult.data!.tryGetSuccess()!,
                      onConfirm: () {
                        // Call delete command
                        viewModel.triggerDocumentDelete();
                      },
                    );
                  },
                );
              }
            }),
          ],
        ],
      ),
      body: Builder(
        builder: (context) {
          if (loadDocResult.isExecuting ||
              !loadDocResult.hasData ||
              loadDocResult.data == null) {
            return const Center(
              child: CircularProgressIndicator(), //
            );
          }

          if (loadDocResult.data!.isError()) {
            final error = loadDocResult.data!.tryGetError()!;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar documento',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.loadDocument.execute(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final documentFile = loadDocResult.data!.tryGetSuccess()!;

          return Stack(
            children: [
              DocumentPdfViewer(
                document: PdfDocument.openFile(documentFile.file.path),
                onPageChanged: (page) {
                  widget.viewModel.currentPage.value = page;
                },
                onDocumentLoaded: (documentFile) {
                  widget.viewModel.totalPages.value = documentFile.pagesCount;
                  widget.viewModel.currentPage.value = 1;
                },
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: PageIndicator(
                    currentPage: widget.viewModel.currentPage,
                    totalPages: widget.viewModel.totalPages,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeleteDocumentDialog extends StatelessWidget {
  const _DeleteDocumentDialog({required this.document, this.onConfirm});

  final DocumentWithFile document;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Excluir Documento'),
      content: Text('''
Tem certeza que deseja excluir "${document.document.titulo}"?
Ele permanecerá disponível na lixeira e será apagado permanentemente em 30 dias.
'''),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          child: const Text('Excluir'),
        ),
      ],
    );
  }
}

class _DocumentActionsMenu extends StatelessWidget {
  final void Function(DocumentAction selectedAction) onSelected;

  const _DocumentActionsMenu(this.onSelected);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => onSelected(DocumentAction.view),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Informações',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        MenuItemButton(
          onPressed: () => onSelected(DocumentAction.edit),
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Editar',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        MenuItemButton(
          onPressed: () => onSelected(DocumentAction.delete),
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: colorScheme.error),
              const SizedBox(width: 8),
              Text('Excluir', style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/document/document.dart';
import '../view_models/document_view_model.dart';

class DocumentView extends StatefulWidget {
  final DocumentViewModel viewModel;
  const DocumentView(this.viewModel, {super.key});

  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  DocumentViewModel get viewModel => widget.viewModel;

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _onErrorChanged(BuildContext context, String? newValue) {
    if (newValue != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(newValue)));
      viewModel.errorMessage.value = null; // Reset after showing
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Document document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Documento'),
          content: Text('Tem certeza que deseja excluir "${document.titulo}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.deleteDocument(document.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final document = watch(viewModel.document).value;
    // final loadingStatus = watch(viewModel.documentLoadingStatus).value;

    // registerHandler<ValueNotifier, String?>(
    //   target: viewModel.errorMessage,
    //   handler: (context, newValue, cancel) {
    //     _onErrorChanged(context, newValue);
    //   },
    // );

    // registerHandler<ValueNotifier, String?>(
    //   target: viewModel.redirectTo,
    //   handler: (context, newValue, cancel) {
    //     if (newValue != null) {
    //       context.go(newValue);
    //     }
    //   },
    // );

    return Scaffold(
      appBar: AppBar(
        title: Text(document?.titulo ?? 'Visualizar Documento'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [
          if (document != null)
            _DocumentActionsMenu((DocumentAction action) {
              if (action == DocumentAction.view) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return _DocumentInfoBottomSheet(document: document);
                  },
                );
              } else if (action == DocumentAction.delete) {
                _showDeleteConfirmationDialog(context, document);
              }
            }),
        ],
      ),
      body: Stack(
        children: [_buildBodyStateWrapper(context, document, loadingStatus)],
      ),
    );
  }

  Widget _buildBodyStateWrapper(
    BuildContext context,
    dynamic document,
    DocumentLoadStatus loadingStatus,
  ) {
    switch (loadingStatus) {
      case DocumentLoadStatus.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando documento...'),
            ],
          ),
        );
      case DocumentLoadStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar documento',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.errorMessage.value ?? 'Erro desconhecido',
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
      case DocumentLoadStatus.loaded:
        return _buildPdfView(context, document);
    }
  }

  Widget _buildPdfView(BuildContext context, dynamic document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: PdfViewPinch(
            controller: viewModel.pdfController!,
            scrollDirection: Axis.vertical,
            onDocumentError: (error) {
              viewModel.documentLoadingStatus.value = DocumentLoadStatus.error;
              viewModel.errorMessage.value = error.toString();
            },
            onDocumentLoaded: (document) {
              debugPrint('PDF loaded: ${document.pagesCount} pages');
            },
            onPageChanged: (page) {
              debugPrint('Current page: $page');
            },
          ),
        ),
      ],
    );
  }
}

class _DocumentInfoBottomSheet extends StatelessWidget {
  const _DocumentInfoBottomSheet({required this.document});

  final Document document;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Informações',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DocumentInfoCard(
                        label: 'Título',
                        value: document.titulo,
                      ),
                      _DocumentInfoCard(
                        label: 'Adicionado em',
                        value: DateFormat(
                          'dd/MM/yyyy',
                        ).format(document.dataAdicao),
                      ),
                      _DocumentInfoCard(
                        label: 'Nome do(a) Paciente',
                        value: document.paciente,
                      ),
                      _DocumentInfoCard(
                        label: 'Nome do(a) Médico(a)',
                        value: document.medico,
                      ),
                      _DocumentInfoCard(
                        label: 'Tipo de Documento',
                        value: document.tipo,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



class _DocumentInfoCard extends StatelessWidget {
  const _DocumentInfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
*/
