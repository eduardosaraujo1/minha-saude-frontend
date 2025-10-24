import 'dart:io';
import 'dart:typed_data';

import 'package:multiple_result/multiple_result.dart';

import 'document_api_client.dart';
import 'models/document_api_model/document_api_model.dart';

class DocumentApiClientImpl implements DocumentApiClient {
  @override
  Future<Result<Uint8List, Exception>> downloadDocument(String uuid) {
    // TODO: implement downloadDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<DocumentApiModel, Exception>> getDocument(String uuid) {
    // TODO: implement getDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<List<DocumentApiModel>, Exception>> listDocuments() {
    // TODO: implement listDocuments
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

  @override
  Future<Result<DocumentApiModel, Exception>> uploadDocument({
    required File file,
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  }) {
    // TODO: implement uploadDocument
    throw UnimplementedError();
  }
}
