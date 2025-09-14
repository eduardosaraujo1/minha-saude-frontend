import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_list_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/document/widgets/document_item.dart';
import 'package:minha_saude_frontend/app/presentation/shared/widgets/brand_app_bar.dart';
import 'package:watch_it/watch_it.dart';

class DocumentListView extends WatchingWidget {
  const DocumentListView(this.viewModel, {super.key});
  final DocumentListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Mock data based on the picture
    final mockData = [
      {
        'person': 'Ana Beatriz Rocha',
        'documents': [
          'Exame de Sangue da Beatriz',
          'Receita pro Zoladex da Ana',
          'Mamografia da Ana Beatriz',
        ],
      },
      {
        'person': 'Daniel Ferreira',
        'documents': [
          'Receita de Haldol do Daniel',
          'Hemograma do Daniel 2020',
          'Hemograma do Daniel 2021',
        ],
      },
      {
        'person': 'Jaqueline Souza',
        'documents': [
          'Tomografia da Jaqueline',
          'Endoscopia da Jaqueline',
          'Mamografia da Jaqueline',
        ],
      },
      {
        'person': 'Marcos Lima',
        'documents': [
          'Hemograma do Marcos',
          'Colonoscopia do Marcos',
          'Tomografia do Marcos',
        ],
      },
    ];

    return Scaffold(
      appBar: BrandAppBar(
        title: const Text('Documentos'),
        action: IconButton(onPressed: () {}, icon: const Icon(Icons.sort)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: mockData.map((personData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personData['person'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: (personData['documents'] as List<String>).length,
                  itemBuilder: (context, index) {
                    final documentTitle =
                        (personData['documents'] as List<String>)[index];
                    return DocumentItem(
                      title: documentTitle,
                      onTap: () {
                        // TODO: Handle document tap
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
        label: Text(
          'Documento',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
