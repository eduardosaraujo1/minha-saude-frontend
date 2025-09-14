import 'package:flutter/material.dart';
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
    final Map<String, List<String>> mockData = {
      'Ana Beatriz Rocha': [
        'Exame de Sangue da Beatriz',
        'Receita pro Zoladex da Ana',
        'Mamografia da Ana Beatriz',
      ],
      'Daniel Ferreira': [
        'Receita de Haldol do Daniel',
        'Hemograma do Daniel 2020',
        'Hemograma do Daniel 2021',
      ],
      'Jaqueline Souza': [
        'Tomografia da Jaqueline',
        'Endoscopia da Jaqueline',
        'Mamografia da Jaqueline',
      ],
      'Marcos Lima': [
        'Hemograma do Marcos',
        'Colonoscopia do Marcos',
        'Tomografia do Marcos',
      ],
    };

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
                    childAspectRatio: 0.8,
                  ),
                  itemCount: entry.value.length,
                  itemBuilder: (context, index) {
                    final documentTitle = entry.value[index];
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
