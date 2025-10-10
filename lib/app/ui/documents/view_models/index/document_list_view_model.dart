import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../domain/models/document/document.dart';
import '../../../../data/repositories/document/document_repository.dart';
import '../../widgets/index/sorted_document_list.dart' show GroupingAlgorithm;

class DocumentListViewModel {
  DocumentListViewModel(this.documentRepository) {
    loadDocuments =
        Command.createAsync<bool, Result<List<Document>, Exception>?>(
          _loadDocuments,
          initialValue: null,
        );

    // When the repository notifies of changes, reload documents
    documentRepository.addListener(() {
      loadDocuments.execute(false);
    });
  }

  final DocumentRepository documentRepository;
  final _log = Logger('document_list_view_model');

  late final Command<bool, Result<List<Document>, Exception>?> loadDocuments;
  final ValueNotifier selectedAlgorithm = ValueNotifier<GroupingAlgorithm>(
    GroupingAlgorithm.paciente,
  );

  Future<void> refresh() async {
    loadDocuments.execute(true);
  }

  Future<Result<List<Document>, Exception>> _loadDocuments(
    bool forceReload,
  ) async {
    final defaultException = Exception(
      "Não foi possível carregar os documentos. Tente novamente mais tarde.",
    );
    final documentsQuery = await documentRepository.listDocuments(
      forceRefresh: forceReload,
    );

    if (documentsQuery.isError()) {
      final exception = documentsQuery.tryGetError()!;
      _log.severe('Failed to load documents: $exception');

      return Result.error(defaultException);
    }

    final fetchedDocuments = documentsQuery.getOrThrow();
    return Result.success(fetchedDocuments);
  }

  GroupingAlgorithm selectAlgorithm(GroupingAlgorithm algorithm) {
    return algorithm;
  }
}
