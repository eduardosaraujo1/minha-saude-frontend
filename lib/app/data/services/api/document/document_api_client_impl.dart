import 'dart:io';
import 'dart:typed_data';
import 'package:multiple_result/multiple_result.dart';

import 'document_api_client.dart';
import 'models/document_api_model.dart';

class DocumentApiClientImpl implements DocumentApiClient {
  @override
  Future<Result<DocumentApiModel, Exception>> documentUpload({
    required File file,
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  }) {
    // TODO: implement documentUpload
    throw UnimplementedError();
  }

  @override
  Future<Result<List<DocumentApiModel>, Exception>> documentsList() {
    // TODO: implement documentsList
    throw UnimplementedError();
  }

  @override
  Future<Result<Uint8List, Exception>> downloadDocument(String uuid) {
    // TODO: implement downloadDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<DocumentApiModel, Exception>> getDocumentMeta(String uuid) {
    // TODO: implement getDocumentMeta
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> trashDocument(String uuid) {
    // TODO: implement trashDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<DocumentApiModel, Exception>> updateDocument(
    String uuid, {
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
