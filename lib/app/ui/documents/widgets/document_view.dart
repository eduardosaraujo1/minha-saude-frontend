import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../view_models/document_view_model.dart';

class DocumentView extends StatelessWidget {
  const DocumentView(this.viewModel, {super.key});

  final DocumentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: viewModel.loadDocument.results,
      builder: (context, loadDocResult, child) {
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
                    log('Delete action selected');
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
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => viewModel.loadDocument.execute(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }

              final documentFile = loadDocResult.data!.tryGetSuccess()!;

              return Stack(
                children: [
                  _DocumentPdfViewer(
                    document: PdfDocument.openFile(documentFile.file.path),
                    onPageChanged: (page) {
                      viewModel.currentPage.value = page;
                    },
                    onDocumentLoaded: (documentFile) {
                      viewModel.totalPages.value = documentFile.pagesCount;
                      viewModel.currentPage.value = 1;
                    },
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _PageCounter(
                        currentPage: viewModel.currentPage,
                        totalPages: viewModel.totalPages,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _PageCounter extends StatefulWidget {
  const _PageCounter({required this.currentPage, required this.totalPages});

  final ValueNotifier<int> currentPage;
  final ValueNotifier<int> totalPages;

  @override
  State<_PageCounter> createState() => _PageCounterState();
}

class _PageCounterState extends State<_PageCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _fadeOutTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Show initially
    _fadeController.forward();
    _scheduleFadeOut();

    // Listen to page changes
    widget.currentPage.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.currentPage.removeListener(_onPageChanged);
    _fadeOutTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    // Cancel any existing timer (debounce behavior)
    _fadeOutTimer?.cancel();

    // Show the counter and schedule fade out
    _fadeController.forward();
    _scheduleFadeOut();
  }

  void _scheduleFadeOut() {
    // Cancel previous timer if it exists
    _fadeOutTimer?.cancel();

    // Create new timer
    _fadeOutTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _fadeController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.totalPages,
      builder: (context, totalPages, child) {
        return ValueListenableBuilder<int>(
          valueListenable: widget.currentPage,
          builder: (context, currentPage, child) {
            var theme = Theme.of(context);
            var colorScheme = theme.colorScheme;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.inverseSurface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$currentPage de $totalPages',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onInverseSurface,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DocumentPdfViewer extends StatefulWidget {
  const _DocumentPdfViewer({
    required this.document,
    this.onPageChanged,
    this.onDocumentLoaded,
  });
  final void Function(int page)? onPageChanged;
  final void Function(PdfDocument doc)? onDocumentLoaded;

  final Future<PdfDocument> document;

  @override
  State<_DocumentPdfViewer> createState() => _DocumentPdfViewerState();
}

class _DocumentPdfViewerState extends State<_DocumentPdfViewer> {
  static bool supportsPinchView = Platform.isAndroid || Platform.isIOS;
  late final dynamic _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = supportsPinchView
        ? PdfControllerPinch(document: widget.document)
        : PdfController(document: widget.document);
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pdfController is PdfControllerPinch) {
      return PdfViewPinch(
        controller: _pdfController,
        scrollDirection: Axis.vertical,
        onPageChanged: widget.onPageChanged,
        onDocumentLoaded: widget.onDocumentLoaded,
      );
    } else if (_pdfController is PdfController) {
      return PdfView(
        controller: _pdfController,
        scrollDirection: Axis.vertical,
        pageSnapping: false,
      );
    } else {
      return Center(
        child: Text(
          'Visualização de PDF não suportada nesta plataforma.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
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
