import 'dart:io';
import 'dart:typed_data';
import 'package:minha_saude_frontend/app/data/services/api/document/document_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/api/document/models/document_api_model.dart';
import 'package:multiple_result/multiple_result.dart';

class DocumentApiClientImpl implements DocumentApiClient {
  @override
  Future<Result<void, Exception>> deleteDocument(String documentId) async {
    // TODO: implement deleteDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> documentUpload({
    required File file,
    String? filename,
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  }) async {
    // TODO: implement documentUpload
    throw UnimplementedError();
  }

  @override
  Future<Result<List<DocumentApiModel>, Exception>> documentsList() async {
    // TODO: implement documentsList
    throw UnimplementedError();
  }

  @override
  Future<Result<Uint8List, Exception>> downloadDocument(String documentId) {
    // TODO: implement downloadDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<DocumentApiModel, Exception>> getDocumentMeta(
    String documentId,
  ) {
    // TODO: implement getDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<DocumentApiModel, Exception>> updateDocument(
    String documentId, {
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  }) {
    // TODO: implement updateDocument
    throw UnimplementedError();
  }
}
