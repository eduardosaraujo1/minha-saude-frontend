import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/document/models/document.dart';
import 'package:minha_saude_frontend/app/data/document/repositories/document_repository.dart';

class DocumentListViewModel {
  final DocumentRepository documentRepository;

  DocumentListViewModel(this.documentRepository) {
    refresh();
  }

  // Cached list of documents
  final documents = ValueNotifier<List<Document>>([]);
  final groupedDocuments = ValueNotifier<Map<String, List<Document>>>({});

  // State for sorting/grouping documents
  final ValueNotifier<GroupAlgorithm> selectedAlgorithm = ValueNotifier(
    GroupAlgorithm.paciente,
  );
  final openFAB = ValueNotifier(false);
  final showSortMenu = ValueNotifier(false);
  final errorMessage = ValueNotifier<String?>(null);

  Future<void> refresh() async {
    final documentsQuery = await documentRepository.listDocuments();

    if (documentsQuery.isError()) {
      errorMessage.value = documentsQuery.tryGetError()!.toString();
      return;
    }

    documents.value = documentsQuery.getOrThrow();

    groupedDocuments.value = groupDocuments(
      documents.value,
      selectedAlgorithm.value,
    );
  }

  Map<String, List<Document>> groupDocuments(
    List<Document> docs,
    GroupAlgorithm algorithm,
  ) {
    final Map<String, List<Document>> grouped = {};

    for (final doc in docs) {
      String key;

      switch (algorithm) {
        case GroupAlgorithm.paciente:
          key = doc.paciente;
          break;
        case GroupAlgorithm.tipo:
          key = doc.tipo;
          break;
        case GroupAlgorithm.medico:
          key = doc.medico;
          break;
        case GroupAlgorithm.data:
          key = _formatDateToMonthYear(doc.dataDocumento);
          break;
      }

      if (grouped.containsKey(key)) {
        grouped[key]!.add(doc);
      } else {
        grouped[key] = [doc];
      }
    }

    return grouped;
  }

  String _formatDateToMonthYear(DateTime date) {
    final months = [
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

    final monthName = months[date.month - 1];
    return '$monthName ${date.year}';
  }

  void setSelectedAlgorithm(GroupAlgorithm algorithm) {
    selectedAlgorithm.value = algorithm;
    groupedDocuments.value = groupDocuments(documents.value, algorithm);
  }
}

enum GroupAlgorithm { paciente, tipo, medico, data }
