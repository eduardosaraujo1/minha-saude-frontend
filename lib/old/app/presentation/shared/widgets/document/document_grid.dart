import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/document/models/document.dart';
import 'package:minha_saude_frontend/app/presentation/shared/widgets/document/document_item.dart';

class DocumentGrid extends StatelessWidget {
  final List<Document> documents;
  final void Function(Document document) onDocumentTap;

  const DocumentGrid({
    super.key,
    required this.documents,
    required this.onDocumentTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return DocumentItem(
          title: document.titulo,
          onTap: () => onDocumentTap(document),
        );
      },
    );
  }
}
