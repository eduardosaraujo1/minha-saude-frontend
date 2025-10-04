import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/utils/command.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../domain/models/document.dart';
import '../../../../data/repositories/document_repository.dart';
import '../../widgets/index/sorted_document_list.dart' show GroupingAlgorithm;

class DocumentListViewModel extends ChangeNotifier {
  // 1. Use CommandPattern (Command0) for handling loading
  // 2. Move the logic for FAB and SortMenu to a comment (In the future, move the FAB and SortMenu to its own dedicated ViewModel)
  // 3. Remove ValueNotifier from everything except the load command (which is a Notifier itself, in other words, no more ValueNotifier in this file)
  final DocumentRepository documentRepository;

  DocumentListViewModel(this.documentRepository) {
    load = Command0(_loadDocuments);
    load.execute();
  }

  final List<Document> documents = <Document>[];
  final _log = Logger('document_list_view_model');

  GroupingAlgorithm selectedAlgorithm = GroupingAlgorithm.paciente;

  // TODO: Move FAB and SortMenu related state into a dedicated ViewModel.

  late final Command0<void, Exception> load;

  Future<void> refresh() async {
    await load.execute();
  }

  Future<Result<void, Exception>> _loadDocuments() async {
    final defaultException = Exception(
      "Não foi possível carregar os documentos. Tente novamente mais tarde.",
    );
    final documentsQuery = await documentRepository.listDocuments();

    if (documentsQuery.isError()) {
      final exception = documentsQuery.tryGetError()!;
      _log.severe('Failed to load documents: $exception');

      return Result.error(defaultException);
    }

    final fetchedDocuments = documentsQuery.getOrThrow();
    documents
      ..clear()
      ..addAll(fetchedDocuments);

    return Result.success(null);
  }

  void setSelectedAlgorithm(GroupingAlgorithm algorithm) {
    if (selectedAlgorithm == algorithm) {
      return;
    }

    selectedAlgorithm = algorithm;
    notifyListeners();
  }
}
