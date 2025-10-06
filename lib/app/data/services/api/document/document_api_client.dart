import 'dart:io';
import 'dart:typed_data';

import 'package:minha_saude_frontend/app/data/services/api/document/models/document_api_model.dart';
import 'package:multiple_result/multiple_result.dart';

// Function names are based on endpoint path, and payload parameters are function parameters
// Response could be either dedicated API MODEL or plain types like void, List<Document>, etc.
abstract class DocumentApiClient {
  // | POST | /documents/upload | {arquivo,titulo?,nomePaciente?,nomeMedico?,tipoDocumento?,dataDocumento?} | {uuid,titulo,nomePaciente?,nomeMedico?,tipoDocumento?,dataDocumento?,createdAt} | Enviar arquivo |
  /// Upload a document file with optional metadata
  Future<Result<DocumentApiModel, Exception>> documentUpload({
    required File file,
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  });

  // | GET | /documents | {} | {data:[{uuid,titulo,nomePaciente?,nomeMedico?,tipoDocumento?,dataDocumento?,createdAt}]} | Listar documentos |
  /// List documents with pagination
  Future<Result<List<DocumentApiModel>, Exception>> documentsList();

  // | GET | /documents/{id} | {} | {uuid,titulo,nomePaciente?,nomeMedico?,tipoDocumento?,dataDocumento?,createdAt,deletedAt?} | Ver documento e metadados |
  /// Get a single document by ID
  Future<Result<DocumentApiModel, Exception>> getDocumentMeta(String uuid);

  // | PUT | /documents/{id} | {titulo?,nomePaciente?,nomeMedico?,tipoDocumento?,dataDocumento?} | {titulo,nomePaciente?,nomeMedico?,tipoDocumento?,dataDocumento?} | Editar metadados |
  /// Update document metadata
  Future<Result<DocumentApiModel, Exception>> updateDocument(
    String uuid, {
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  });

  // | DELETE | /documents/{id} | {} | {} | Apagar (lixeira) |
  /// Move a document to trash (soft delete)
  Future<Result<void, Exception>> trashDocument(String uuid);

  // | GET | /documents/{id}/download | {} | {arquivo?} | Baixar e/ou imprimir |
  /// Download a document - returns Dio Response with bytes
  /// The caller is responsible for saving the file or opening it
  Future<Result<Uint8List, Exception>> downloadDocument(String uuid);
}
