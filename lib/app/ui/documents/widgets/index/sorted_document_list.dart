import 'package:flutter/material.dart';

import '../../../../domain/models/document/document.dart';
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

  static const _months = <String>[
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static const _uncategorizedLabel = 'Não organizado';

  Map<String, List<Document>> _groupDocuments() {
    final Map<String, List<Document>> grouped = {};

    for (final document in documents) {
      final key = _resolveGroupKey(document);
      grouped.putIfAbsent(key, () => <Document>[]).add(document);
    }

    return grouped;
  }

  String _resolveGroupKey(Document document) {
    switch (groupingAlgorithm) {
      case GroupingAlgorithm.paciente:
        return _normalizeKey(document.paciente);
      case GroupingAlgorithm.tipo:
        return _normalizeKey(document.tipo);
      case GroupingAlgorithm.medico:
        return _normalizeKey(document.medico);
      case GroupingAlgorithm.data:
        return _normalizeDateKey(document.dataDocumento);
    }
  }

  String _normalizeKey(String? value) {
    if (value == null) {
      return _uncategorizedLabel;
    }

    final normalized = value.trim();

    if (normalized.isEmpty) {
      return _uncategorizedLabel;
    }

    return normalized;
  }

  String _normalizeDateKey(DateTime? date) {
    if (date == null) {
      return _uncategorizedLabel;
    }
    final monthName = _months[date.month - 1];
    return '$monthName ${date.year}';
  }

  List<String> _sortedKeys(Iterable<String> keys) {
    if (groupingAlgorithm == GroupingAlgorithm.data) {
      return keys.toList();
    }

    final result = keys.toList()
      ..sort((a, b) {
        if (a == _uncategorizedLabel) {
          return -1;
        }
        if (b == _uncategorizedLabel) {
          return 1;
        }
        return a.compareTo(b);
      });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final groupedDocuments = _groupDocuments();
    final sortedKeys = _sortedKeys(groupedDocuments.keys);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sortedKeys.map((key) {
        final groupDocuments = groupedDocuments[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              key, //
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
