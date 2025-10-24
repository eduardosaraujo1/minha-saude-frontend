import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/services/api/clients/document/models/document_api_model/document_api_model.dart';
import 'package:minha_saude_frontend/app/data/services/api/fakes/fake_server_database.dart';
import 'package:minha_saude_frontend/app/data/services/api/fakes/fake_server_file_storage.dart';
import 'package:multiple_result/multiple_result.dart';

import 'trash_api_client.dart';

class FakeTrashApiClient extends TrashApiClient {
  FakeTrashApiClient({
    required this.fakeServerDatabase,
    required this.fakeServerFileStorage,
  });

  final FakeServerDatabase fakeServerDatabase;
  final FakeServerFileStorage fakeServerFileStorage;
  final _logger = Logger('FakeTrashApiClient');

  // Helper to get the current user (in fake, we just use the first user)
  Future<int?> _getCurrentUserId() async {
    final users = await fakeServerDatabase.users.readAll();
    if (users.isEmpty) return null;
    return users.first['id'] as int;
  }

  @override
  Future<Result<void, Exception>> destroyTrashDocument(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Permanently delete the document
      await fakeServerDatabase.documents.hardDeleteByUuid(id);

      // Delete the file from storage
      final fileResult = await fakeServerFileStorage.delete(id);
      if (fileResult.isError()) {
        _logger.warning(
          'Failed to delete file from storage: ${fileResult.tryGetError()}',
        );
      }

      return Success(null);
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

      final docData = await fakeServerDatabase.documents.findByUuid(id);
      if (docData == null || docData['deleted_at'] == null) {
        return Result.error(Exception('Document not found in trash'));
      }

      return Success(
        DocumentApiModel(
          uuid: docData['uuid'] as String,
          titulo: docData['titulo'] as String,
          nomePaciente: docData['nome_paciente'] as String?,
          nomeMedico: docData['nome_medico'] as String?,
          tipoDocumento: docData['tipo_documento'] as String?,
          dataDocumento: docData['data_documento'] != null
              ? DateTime.parse(docData['data_documento'] as String)
              : null,
          createdAt: DateTime.parse(docData['created_at'] as String),
        ),
      );
    } catch (e, s) {
      _logger.severe('Failed to get document: $e', e, s);
      return Result.error(Exception('Failed to get document: $e'));
    }
  }

  @override
  Future<Result<List<DocumentApiModel>, Exception>> listTrashDocuments() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Success([]);
      }

      // Query all deleted documents for this user
      final documents = await fakeServerDatabase.documents.findDeletedByUser(
        userId,
      );

      // Convert to DocumentApiModel
      final documentModels = documents.map((doc) {
        return DocumentApiModel(
          uuid: doc['uuid'] as String,
          titulo: doc['titulo'] as String,
          nomePaciente: doc['nome_paciente'] as String?,
          nomeMedico: doc['nome_medico'] as String?,
          tipoDocumento: doc['tipo_documento'] as String?,
          dataDocumento: doc['data_documento'] != null
              ? DateTime.parse(doc['data_documento'] as String)
              : null,
          createdAt: DateTime.parse(doc['created_at'] as String),
        );
      }).toList();

      return Success(documentModels);
    } catch (e, s) {
      _logger.severe('Failed to list documents: $e', e, s);
      return Result.error(Exception('Failed to list documents: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> restoreTrashDocument(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Restore the document by clearing deleted_at
      await fakeServerDatabase.documents.updateByUuid(id, {'deleted_at': null});

      return Success(null);
    } catch (e, s) {
      _logger.severe('Failed to restore document: $e', e, s);
      return Result.error(Exception('Failed to restore document: $e'));
    }
  }
}
