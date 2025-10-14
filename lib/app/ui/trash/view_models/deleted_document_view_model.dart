import 'package:command_it/command_it.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/document/document.dart';
import '../../../data/repositories/trash/trash_repository.dart';

class DeletedDocumentViewModel {
  DeletedDocumentViewModel({
    required this.documentUuid,
    required this.trashRepository,
  }) {
    loadDocument = Command.createAsyncNoParam(
      _loadDocument,
      initialValue: null,
    );
    deleteDocumentForever = Command.createAsyncNoParam(
      _deleteDocumentForever,
      initialValue: null,
    );
    restoreDocument = Command.createAsyncNoParam(
      _restoreDocument,
      initialValue: null,
    );
  }

  final String documentUuid;
  final TrashRepository trashRepository;

  late final Command<void, Result<Document, Exception>?> loadDocument;
  late final Command<void, Result<void, Exception>?> deleteDocumentForever;
  late final Command<void, Result<void, Exception>?> restoreDocument;

  Future<Result<Document, Exception>?> _loadDocument() {
    return _wrapWithErrorHandling(() async {
      final response = await trashRepository.getTrashDocument(documentUuid);

      return response.when(
        (success) {
          return Success(success);
        },
        (error) {
          return Error(Exception("Não foi possível carregar o documento."));
        },
      );
    });
  }

  Future<Result<void, Exception>?> _restoreDocument() async {
    return _wrapWithErrorHandling(() async {
      final response = await trashRepository.restoreTrashDocument(documentUuid);

      return response.when(
        (success) {
          return Success(null);
        },
        (error) {
          return Error(Exception("Não foi possível restaurar o documento."));
        },
      );
    });
  }

  Future<Result<void, Exception>?> _deleteDocumentForever() async {
    return _wrapWithErrorHandling(() async {
      final response = await trashRepository.destroyTrashDocument(documentUuid);

      return response.when(
        (success) {
          return Success(null);
        },
        (error) {
          return Error(Exception("Não foi possível restaurar o documento."));
        },
      );
    });
  }

  Future<Result<T, Exception>> _wrapWithErrorHandling<T>(
    Future<Result<T, Exception>> Function() func,
  ) async {
    try {
      return await func();
    } catch (e) {
      return Error(Exception('Ocorreu um erro inesperado.'));
    }
  }
}
