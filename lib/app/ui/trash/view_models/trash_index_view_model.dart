import 'package:command_it/command_it.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/document/document.dart';
import '../../../data/repositories/trash/trash_repository.dart';

class TrashIndexViewModel {
  TrashIndexViewModel({required this.trashRepository}) {
    loadDocuments = Command.createAsync(
      (p) => _loadDocument(forceRefresh: p),
      initialValue: null,
    );
  }

  final TrashRepository trashRepository;

  late final Command<bool, Result<List<Document>, Exception>?> loadDocuments;

  Future<Result<List<Document>, Exception>?> _loadDocument({
    forceRefresh = false,
  }) async {
    try {
      final result = await trashRepository.listTrashDocuments(
        forceRefresh: forceRefresh,
      );

      if (result.isError()) {
        return Error(Exception("Ocorreu um erro ao carregar os documentos."));
      }

      return result;
    } catch (e) {
      return Error(Exception("Ocorreu um erro ao carregar os documentos."));
    }
  }

  void reloadDocuments() {
    loadDocuments.execute(true);
  }
}
