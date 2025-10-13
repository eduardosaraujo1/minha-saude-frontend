import 'package:minha_saude_frontend/app/data/services/api/document/models/document_api_model.dart';
import 'package:multiple_result/multiple_result.dart';

abstract class TrashApiClient {
  // | GET    | /trash              | Listar documentos       |
  /// List documents in trash
  Future<Result<List<DocumentApiModel>, Exception>> listTrashDocuments();

  // | GET    | /trash/{id}         | Ver documento           |
  /// Get document in trash by id
  Future<Result<DocumentApiModel, Exception>> getTrashDocument(String id);

  // | POST   | /trash/{id}/restore | Restaurar documento     |
  /// Restore document in trash by id
  Future<Result<void, Exception>> restoreTrashDocument(String id);

  // | POST   | /trash/{id}/destroy | Excluir permanentemente |
  /// Permanently delete document in trash by id
  Future<Result<void, Exception>> destroyTrashDocument(String id);
}
