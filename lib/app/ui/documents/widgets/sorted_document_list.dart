import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/document.dart';
import 'document_item.dart';

class SortedDocumentList extends StatelessWidget {
  const SortedDocumentList({
    super.key,
    required this.documents,
    required this.groupingAlgorithm,
    required this.onDocumentTap,
  });

  final List<Document> documents;
  final GroupingAlgorithm groupingAlgorithm;
  final void Function(Document document) onDocumentTap;

  Map<String, List<Document>> _groupDocuments() {
    final Map<String, List<Document>> grouped = {};

    for (final document in documents) {
      String key;
      switch (groupingAlgorithm) {
        case GroupingAlgorithm.paciente:
          key = document.paciente;
          break;
        case GroupingAlgorithm.tipo:
          key = document.tipo;
          break;
        case GroupingAlgorithm.medico:
          key = document.medico;
          break;
        case GroupingAlgorithm.data:
          key = DateFormat('dd/MM/yyyy').format(document.dataDocumento);
          break;
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(document);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedDocuments = _groupDocuments();
    final sortedKeys = groupedDocuments.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedKeys.map((key) {
        final groupDocuments = groupedDocuments[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(key, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: groupDocuments.map((document) {
                return DocumentItem(
                  title: document.titulo,
                  onTap: () => onDocumentTap(document),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}

enum GroupingAlgorithm { paciente, tipo, medico, data }
