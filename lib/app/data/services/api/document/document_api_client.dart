import 'dart:io';
import 'dart:typed_data';

import 'package:minha_saude_frontend/app/data/services/api/document/models/document_api_model.dart';
import 'package:multiple_result/multiple_result.dart';

// Function names are based on endpoint path, and payload parameters are function parameters
// Response could be either dedicated API MODEL or plain types like void, List<Document>, etc.
abstract class DocumentApiClient {
  // | Método | Endpoint                 | Payload                                                                          | Response                                                                                                                                                                                                                   | Descrição                 |
  // | ------ | ------------------------ | -------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |

  // | POST   | /documents/upload        | {arquivos[],titulo?,nomePaciente?,nomeMedico?,tipoDocumento?,dataDocumento?} | {status,message?}                                                                                                 | Enviar arquivo            |
  /// Upload a document file with optional metadata
  Future<Result<void, Exception>> documentUpload({
    required File file,
    String? filename,
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  });

  // | GET    | /documents               | {}                                                                           | {data:[{idDocumento,titulo,nomePaciente?,nomeMedico?,tipoDocumento?,dataDocumento?,createdAt}]}                   | Listar documentos         |
  /// List documents with pagination
  Future<Result<List<DocumentApiModel>, Exception>> documentsList();

  // | GET    | /documents/{id}          | {} | {idDocumento,titulo,nomePaciente?,nomeMedico?,tipoDocumento?,dataDocumento?,createdAt,deletedAt?} | Ver metadados documento |
  /// Get a single document by ID
  Future<Result<DocumentApiModel, Exception>> getDocumentMeta(
    String documentId,
  );

  // | PUT    | /documents/{id}          | {idDocumento,titulo?,nomePaciente?,nomeMedico?,tipoDocumento?,dataDocumento?}            | {idDocumento,titulo,nomePaciente?,nomeMedico?,tipoDocumento?,dataDocumento?}                                      | Editar metadados          |
  /// Update document metadata
  Future<Result<DocumentApiModel, Exception>> updateDocument(
    String documentId, {
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  });

  // | DELETE | /documents/{id}          | {}                                                                           | {message,dataExclusao}                                                                                            | Apagar (lixeira)          |
  /// Delete a document (soft delete)
  Future<Result<void, Exception>> deleteDocument(String documentId);

  // | GET    | /documents/{id}/download | {}                                                                           | {arquivoBase64?,linkDownload?}                                                                                    | Baixar e/ou imprimir      |
  /// Download a document - returns Dio Response with bytes
  /// The caller is responsible for saving the file or opening it
  Future<Result<Uint8List, Exception>> downloadDocument(String documentId);
}
