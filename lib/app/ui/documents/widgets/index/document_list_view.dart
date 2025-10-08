import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/ui/documents/widgets/index/document_upload_fab.dart';

import '../../../../routing/routes.dart';
import '../../../core/widgets/brand_app_bar.dart';
import '../../view_models/index/document_list_view_model.dart';
import 'sorted_document_list.dart';

// TODO: show empty state when there are no documents
class DocumentListView extends StatefulWidget {
  final DocumentListViewModel viewModel;

  const DocumentListView(this.viewModel, {super.key});

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  DocumentListViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    viewModel.load.addListener(_onLoadUpdate);
    viewModel.addListener(_onUpdate);
  }

  @override
  void dispose() {
    viewModel.load.removeListener(_onLoadUpdate);
    viewModel.removeListener(_onUpdate);

    super.dispose();
  }

  void _onLoadUpdate() {
    if (!mounted) return;
    if (viewModel.load.isExecuting) return;

    if (viewModel.load.isError) {
      final error = viewModel.load.result?.tryGetError();

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandAppBar(
        title: const Text('Documentos'),
        action: IconButton(
          onPressed: () {},
          icon: _SortMenu(onSelected: viewModel.setSelectedAlgorithm),
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel.load,
        builder: (context, child) {
          if (viewModel.load.isExecuting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.load.isError) {
            return Center(
              child: Text(
                viewModel.load.result?.tryGetError().toString() ??
                    'Erro ao carregar documentos.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              viewModel.load.execute(true);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (viewModel.documents.isEmpty)
                    Center(
                      child: Text(
                        'Nenhum documento encontrado.\nClique no botão abaixo para adicionar.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  SortedDocumentList(
                    documents: viewModel.documents,
                    groupingAlgorithm: viewModel.selectedAlgorithm,
                    onDocumentTap: (document) {
                      context.go('/documentos/${document.uuid}');
                    },
                  ),
                  SizedBox(height: 60),
                ],
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

  final void Function(GroupingAlgorithm) onSelected;

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
