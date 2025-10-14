import 'package:flutter/material.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/document/document.dart';

abstract class TrashRepository extends ChangeNotifier {
  /// List documents in trash and store in internal cache
  Future<Result<List<Document>, Exception>> listTrashDocuments({
    forceRefresh = false,
  });

  /// Get document in trash by id
  Future<Result<Document, Exception>> getTrashDocument(String id);

  // | POST   | /trash/{id}/restore | Restaurar documento     |
  /// Restore document in trash by id
  Future<Result<void, Exception>> restoreTrashDocument(String id);

  // | POST   | /trash/{id}/destroy | Excluir permanentemente |
  /// Permanently delete document in trash by id
  Future<Result<void, Exception>> destroyTrashDocument(String id);
}
