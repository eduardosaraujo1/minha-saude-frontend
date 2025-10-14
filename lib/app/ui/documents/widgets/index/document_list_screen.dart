import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';
import '../../../core/widgets/brand_app_bar.dart';
import '../../view_models/index/document_list_view_model.dart';
import 'document_upload_fab.dart';
import 'sorted_document_list.dart';

class DocumentListScreen extends StatefulWidget {
  final DocumentListViewModel viewModel;

  const DocumentListScreen(this.viewModel, {super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadDocuments.addListener(_onLoadUpdate);
  }

  @override
  void didUpdateWidget(DocumentListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.loadDocuments.removeListener(_onLoadUpdate);
      widget.viewModel.loadDocuments.addListener(_onLoadUpdate);
    }
  }

  @override
  void dispose() {
    widget.viewModel.loadDocuments.removeListener(_onLoadUpdate);
    super.dispose();
  }

  void _onLoadUpdate() {
    if (!mounted) return;

    if (widget.viewModel.loadDocuments.value == null) {
      // Initial state
      return;
    }

    if (widget.viewModel.loadDocuments.value!.isError()) {
      final error = widget.viewModel.loadDocuments.value!.tryGetError()!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: BrandAppBar(
        title: const Text('Documentos'),
        action: IconButton(
          onPressed: () {},
          icon: _SortMenu(
            onSelected: (GroupingAlgorithm algorithm) {
              widget.viewModel.selectedAlgorithm.value = algorithm;
            },
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: widget.viewModel.loadDocuments.results,
        builder: (context, documentState, child) {
          if (documentState.isExecuting || !documentState.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (documentState.data!.isError()) {
            return Center(
              child: Text(
                "Não foi possível carregar os documentos. Tente novamente mais tarde.",
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          final documents = UnmodifiableListView(
            documentState.data!.tryGetSuccess()!,
          );

          return RefreshIndicator(
            onRefresh: () async {
              widget.viewModel.refresh();
            },
            child: SizedBox(
              height: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (documents.isEmpty)
                      Center(
                        child: Text(
                          'Nenhum documento encontrado.\nClique no botão abaixo para adicionar.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    if (documents.isNotEmpty)
                      ValueListenableBuilder(
                        valueListenable: widget.viewModel.selectedAlgorithm,
                        builder: (context, value, child) {
                          return SortedDocumentList(
                            documents: documents,
                            groupingAlgorithm: value,
                            onDocumentTap: (document) {
                              var documentosWithId = Routes.documentosWithId(
                                document.uuid,
                              );
                              context.go(documentosWithId);
                            },
                          );
                        },
                      ),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: DocumentUploadFab(
        onScanTap: () {
          context.go(Routes.documentosScan);
        },
        onUploadTap: () {
          context.go(Routes.documentosUpload);
        },
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.onSelected});

  final void Function(GroupingAlgorithm algorithm) onSelected;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: <Widget>[
        MenuItemButton(
          onPressed: () => onSelected(GroupingAlgorithm.paciente),
          child: const Text('Agrupar por Paciente'),
        ),
        MenuItemButton(
          onPressed: () => onSelected(GroupingAlgorithm.tipo),
          child: const Text('Agrupar por Tipo'),
        ),
        MenuItemButton(
          onPressed: () => onSelected(GroupingAlgorithm.medico),
          child: const Text('Agrupar por Médico'),
        ),
        MenuItemButton(
          onPressed: () => onSelected(GroupingAlgorithm.data),
          child: const Text('Agrupar por Data'),
        ),
      ],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.sort),
            );
          },
    );
  }
}
