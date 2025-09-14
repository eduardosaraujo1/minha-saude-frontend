import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/document/models/document.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_list_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/document/widgets/document_fab.dart';
import 'package:minha_saude_frontend/app/presentation/document/widgets/document_item.dart';
import 'package:minha_saude_frontend/app/presentation/shared/widgets/brand_app_bar.dart';
import 'package:watch_it/watch_it.dart';

class DocumentListView extends WatchingStatefulWidget {
  final DocumentListViewModel viewModel;

  const DocumentListView(this.viewModel, {super.key});

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  DocumentListViewModel get viewModel => widget.viewModel;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Document>> documents = watch(
      viewModel.groupedDocuments,
    ).value;

    registerHandler<ValueNotifier, String?>(
      target: viewModel.errorMessage,
      handler: (context, newValue, cancel) {
        _onErrorChanged(context, newValue);
      },
    );

    // UI
    return Scaffold(
      appBar: BrandAppBar(
        title: const Text('Documentos'),
        action: IconButton(
          onPressed: () {},
          icon: _SortMenu(onSelected: viewModel.setSelectedAlgorithm),
        ),
      ),
      body: documents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._makeDocumentGroups(context, documents),
                  SizedBox(height: 60),
                ],
              ),
            ),
      floatingActionButton: DocumentFab(
        fabLabel: 'Documento',
        menuItems: [
          DocumentFabMenuItem(
            label: 'Escanear',
            icon: Icons.camera_alt,
            onPressed: () {
              context.go("/documentos/scan");
            },
          ),
          DocumentFabMenuItem(
            label: 'Upload',
            icon: Icons.upload_file,
            onPressed: () {
              context.go("/documentos/upload");
            },
          ),
        ],
      ),
    );
  }

  void _onErrorChanged(BuildContext context, String? newValue) {
    if (newValue != null && newValue.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newValue),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      viewModel.clearErrorMessage();
    }
  }

  List<Widget> _makeDocumentGroups(
    BuildContext context,
    Map<String, List<Document>> documents,
  ) {
    return documents.entries
        .map(
          (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: entry.value.length,
                itemBuilder: (context, index) {
                  final documentTitle = entry.value[index].titulo;
                  return DocumentItem(
                    title: documentTitle,
                    onTap: () {
                      context.go('/documentos/${entry.value[index].id}');
                    },
                  );
                },
              ),
            ],
          ),
        )
        .toList();
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.onSelected});

  final void Function(GroupAlgorithm) onSelected;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: <Widget>[
        MenuItemButton(
          onPressed: () => onSelected(GroupAlgorithm.paciente),
          child: const Text('Agrupar por Paciente'),
        ),
        MenuItemButton(
          onPressed: () => onSelected(GroupAlgorithm.tipo),
          child: const Text('Agrupar por Tipo'),
        ),
        MenuItemButton(
          onPressed: () => onSelected(GroupAlgorithm.medico),
          child: const Text('Agrupar por Médico'),
        ),
        MenuItemButton(
          onPressed: () => onSelected(GroupAlgorithm.data),
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
