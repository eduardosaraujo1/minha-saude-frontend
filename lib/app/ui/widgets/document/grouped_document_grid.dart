import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/domain/models/document.dart';
import 'package:minha_saude_frontend/app/ui/widgets/document/document_grid.dart';

class GroupedDocumentGrid extends StatelessWidget {
  final Map<String, List<Document>> groupedDocuments;
  final void Function(Document document) onDocumentTap;

  const GroupedDocumentGrid({
    super.key,
    required this.groupedDocuments,
    required this.onDocumentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedDocuments.entries
          .map(
            (entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                DocumentGrid(
                  documents: entry.value,
                  onDocumentTap: onDocumentTap,
                ),
                const SizedBox(height: 16),
              ],
            ),
          )
          .toList(),
    );
  }
}
