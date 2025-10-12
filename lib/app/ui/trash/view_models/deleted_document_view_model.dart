import 'package:command_it/command_it.dart';
import 'package:multiple_result/multiple_result.dart';

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

  late final Command<void, Result<void, Exception>?> loadDocument;
  late final Command<void, Result<void, Exception>?> deleteDocumentForever;
  late final Command<void, Result<void, Exception>?> restoreDocument;

  Future<Result<void, Exception>?> _loadDocument() async {
    throw UnimplementedError();
  }

  Future<Result<void, Exception>?> _restoreDocument() async {
    throw UnimplementedError();
  }

  Future<Result<void, Exception>?> _deleteDocumentForever() async {
    throw UnimplementedError();
  }
}
