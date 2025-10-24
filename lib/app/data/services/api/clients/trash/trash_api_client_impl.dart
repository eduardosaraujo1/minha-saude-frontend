import 'package:multiple_result/multiple_result.dart';

import '../document/models/document_api_model/document_api_model.dart';
import 'trash_api_client.dart';

class TrashApiClientImpl implements TrashApiClient {
  @override
  Future<Result<void, Exception>> destroyTrashDocument(String id) {
    // TODO: implement destroyTrashDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<DocumentApiModel, Exception>> getTrashDocument(String id) {
    // TODO: implement getTrashDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<List<DocumentApiModel>, Exception>> listTrashDocuments() {
    // TODO: implement listTrashDocuments
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> restoreTrashDocument(String id) {
    // TODO: implement restoreTrashDocument
    throw UnimplementedError();
  }
}
