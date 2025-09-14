import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/document/models/document.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_list_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/document/widgets/document_fab.dart';
import 'package:minha_saude_frontend/app/presentation/document/widgets/document_item.dart';
import 'package:minha_saude_frontend/app/presentation/shared/widgets/brand_app_bar.dart';
import 'package:watch_it/watch_it.dart';

class DocumentListView extends WatchingWidget {
  const DocumentListView(this.viewModel, {super.key});
  final DocumentListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Mock data as map with category names as keys
    final Map<String, List<Document>> mockData = watch(
      viewModel.groupedDocuments,
    ).value;

    return Scaffold(
      appBar: BrandAppBar(
        title: const Text('Documentos'),
        action: IconButton(onPressed: () {}, icon: const Icon(Icons.sort)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: mockData.entries.map((entry) {
            return Column(
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
                        // TODO: Handle document tap
                      },
                    );
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: DocumentFab(
        fabLabel: 'Documento',
        menuItems: [
          DocumentFabMenuItem(
            label: 'Escanear',
            icon: Icons.camera_alt,
            onPressed: () {
              // TODO: Handle scan document
            },
          ),
          DocumentFabMenuItem(
            label: 'Upload',
            icon: Icons.upload_file,
            onPressed: () {
              // TODO: Handle upload document
            },
          ),
        ],
      ),
    );
  }
}
