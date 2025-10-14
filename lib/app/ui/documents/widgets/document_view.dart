import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:pdfx/pdfx.dart';

import '../../../routing/routes.dart';
import '../view_models/document_view_model.dart';
import '../../core/widgets/document_pdf_viewer.dart';
import 'page_indicator.dart';

class DocumentView extends StatefulWidget {
  const DocumentView(this._viewModel, {super.key});

  final DocumentViewModel _viewModel;

  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  @override
  void initState() {
    super.initState();
    widget._viewModel.deleteDocument.addListener(_handleDeleteDocument);
  }

  @override
  void didUpdateWidget(DocumentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._viewModel != widget._viewModel) {
      oldWidget._viewModel.deleteDocument.removeListener(_handleDeleteDocument);
      widget._viewModel.deleteDocument.addListener(_handleDeleteDocument);
    }
  }

  @override
  void dispose() {
    widget._viewModel.deleteDocument.removeListener(_handleDeleteDocument);
    super.dispose();
  }

  void _handleDeleteDocument() {
    final command = widget._viewModel.deleteDocument;

    if (command.isExecuting.value || command.value == null) {
      return;
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

  void _handleActionMenuClick(DocumentAction action) {
    if (action == DocumentAction.view) {
      final infoRoute = Routes.documentosInfo(widget._viewModel.documentUuid);
      context.go(infoRoute);
    } else if (action == DocumentAction.edit) {
      final documentosEdit = Routes.documentosEdit(
        widget._viewModel.documentUuid,
      );
      context.go(documentosEdit);
    } else if (action == DocumentAction.delete) {
      _showDeleteDocumentDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Documento'),
        actions: [_DocumentActionsMenu(_handleActionMenuClick)],
      ),
      body: ValueListenableBuilder(
        valueListenable: widget._viewModel.loadDocument,
        builder: (context, docResult, child) {
          if (docResult == null) {
            return const Center(
              child: CircularProgressIndicator(), //
            );
          }

          if (docResult.isError()) {
            final error = docResult.tryGetError()!;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar documento',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget._viewModel.loadDocument.execute(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final document = docResult.tryGetSuccess()!;

          return Stack(
            children: [
              DocumentPdfViewer(
                document: PdfDocument.openFile(document.file.path),
                onPageChanged: (page) {
                  widget._viewModel.currentPage.value = page;
                },
                onDocumentLoaded: (documentFile) {
                  // Store page state for use in PageIndicator
                  widget._viewModel.totalPages.value = documentFile.pagesCount;
                  widget._viewModel.currentPage.value = 1;
                },
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: PageIndicator(
                    currentPage: widget._viewModel.currentPage,
                    totalPages: widget._viewModel.totalPages,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDocumentDialog(BuildContext context) {
    final document = widget._viewModel.loadDocument.value
        ?.tryGetSuccess()
        ?.document;
    if (document == null) {
      return; // Document info unavailable, cannot delete
    }

    showDialog(
      context: context,
      builder: (context) {
        return _DeleteDocumentDialog(
          document: document,
          onConfirm: () {
            widget._viewModel.triggerDocumentDelete();
          },
        );
      },
    );
  }
}

class _DeleteDocumentDialog extends StatelessWidget {
  const _DeleteDocumentDialog({required this.document, this.onConfirm});

  final Document document;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Tem certeza que deseja excluir esse documento?'),
      content: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          children: [
            TextSpan(text: 'O documento ', style: theme.textTheme.bodyMedium),
            TextSpan(
              text: '«${document.titulo}»',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text:
                  ' será movido para a lixeira. Você pode restaurá-lo ou excluí-lo permanentemente mais tarde.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
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
