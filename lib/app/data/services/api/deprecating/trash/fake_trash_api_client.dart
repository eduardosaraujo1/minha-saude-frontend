import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/services/api/deprecating/document/models/document_api_model.dart';
import 'package:minha_saude_frontend/app/data/services/api/fakes/deprecating/fake_document_server_storage.dart';
import 'package:multiple_result/multiple_result.dart';

import 'trash_api_client.dart';

class FakeTrashApiClient extends TrashApiClient {
  FakeTrashApiClient({required this.serverStorage});

  final FakeDocumentServerStorage serverStorage;
  final _logger = Logger('FakeTrashApiClient');

  @override
  Future<Result<void, Exception>> destroyTrashDocument(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return await serverStorage.permanentlyDeleteDocument(id);
    } catch (e, s) {
      _logger.severe('Failed to permanently delete document: $e', e, s);
      return Result.error(
        Exception('Failed to permanently delete document: $e'),
      );
    }
  }

  @override
  Future<Result<DocumentApiModel, Exception>> getTrashDocument(
    String id,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return await serverStorage.queryDeletedDocumentMetadata(id);
    } catch (e, s) {
      _logger.severe('Failed to get document: $e', e, s);
      return Result.error(Exception('Failed to get document: $e'));
    }
  }

  @override
  Future<Result<List<DocumentApiModel>, Exception>> listTrashDocuments() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return await serverStorage.queryDeletedDocumentList();
    } catch (e, s) {
      _logger.severe('Failed to list documents: $e', e, s);
      return Result.error(Exception('Failed to list documents: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> restoreTrashDocument(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return await serverStorage.restoreDocument(id);
    } catch (e, s) {
      _logger.severe('Failed to restore document: $e', e, s);
      return Result.error(Exception('Failed to restore document: $e'));
    }
  }
}
