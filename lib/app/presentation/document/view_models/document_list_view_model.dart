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
  }

  // Map<String, List<Document>> groupDocuments(
  //     List<Document> docs, GroupAlgorithm algorithm) {
  //   final Map<String, List<Document>> grouped = {};

  //   for (var doc in docs) {
  //     String key;
  //     switch (algorithm) {
  //       case GroupAlgorithm.paciente:
  //         key = doc.paciente;
  //         break;
  //       case GroupAlgorithm.tipo:
  //         key = doc.tipo;
  //         break;
  //       case GroupAlgorithm.data:
  //         key = doc.data.toIso8601String().split('T').first; // YYYY-MM-DD
  //         break;
  //     }

  //     if (!grouped.containsKey(key)) {
  //       grouped[key] = [];
  //     }
  //     grouped[key]!.add(doc);
  //   }

  //   return grouped;
  // }
}

enum GroupAlgorithm { paciente, tipo, medico, data }
