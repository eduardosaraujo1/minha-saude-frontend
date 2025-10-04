import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/document.dart';
import '../../core/widgets/brand_app_bar.dart';
import '../view_models/document_list_view_model.dart';
// import 'package:minha_saude_frontend/app/ui/view_models/document/document_list_view_model.dart';
// import 'package:minha_saude_frontend/app/ui/widgets/document/document_fab.dart';
// import 'package:minha_saude_frontend/app/ui/widgets/app/brand_app_bar.dart';
// import 'package:minha_saude_frontend/app/ui/widgets/document/grouped_document_grid.dart';

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

    viewModel.addListener(_onUpdate);
  }

  @override
  void dispose() {
    viewModel.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    setState(() {});
  }

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
                  GroupedDocumentGrid(
                    groupedDocuments: documents,
                    onDocumentTap: (document) {
                      context.go('/documentos/${document.id}');
                    },
                  ),
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
