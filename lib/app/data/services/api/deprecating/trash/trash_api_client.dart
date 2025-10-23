import 'package:minha_saude_frontend/app/data/services/api/deprecating/document/models/document_api_model.dart';
import 'package:multiple_result/multiple_result.dart';

abstract class TrashApiClient {
  /// List documents in trash
  Future<Result<List<DocumentApiModel>, Exception>> listTrashDocuments();

  /// Get document in trash by id
  Future<Result<DocumentApiModel, Exception>> getTrashDocument(String id);

  /// Restore document in trash by id
  Future<Result<void, Exception>> restoreTrashDocument(String id);

  /// Permanently delete document in trash by id
  Future<Result<void, Exception>> destroyTrashDocument(String id);
}
