part of 'fake_api_gateway.dart';

class _TrashController {
  _TrashController({
    required this.fakeServerDatabase,
    required this.fakeServerCacheEngine,
    required this.fakeServerFileStorage,
  });
  final FakeServerCacheEngine fakeServerCacheEngine;
  final FakeServerDatabase fakeServerDatabase;
  final FakeServerFileStorage fakeServerFileStorage;

  // Helper to get the current user (in fake, we just use the first user)
  Future<Map<String, dynamic>?> _getCurrentUser() async {
    final users = await fakeServerDatabase.users.readAll();
    return users.isEmpty ? null : users.first;
  }

  /// GET /trash - List documents in trash (paginated)
  ///
  /// Response: Paginated list with trash documents
  Future<Result<Map<String, dynamic>, ApiGatewayException>> listTrash() async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ClientException('User not found'));
      }

      final userId = user['id'] as int;
      final docs = await fakeServerDatabase.documents.findDeletedByUser(userId);

      final data = docs.map((doc) {
        return {
          'id': doc['id'],
          'uuid': doc['uuid'],
          'titulo': doc['titulo'],
          'nomePaciente': doc['nome_paciente'],
          'nomeMedico': doc['nome_medico'],
          'tipoDocumento': doc['tipo_documento'],
          'dataDocumento': doc['data_documento'],
          'createdAt': doc['created_at'],
          'deletedAt': doc['deleted_at'],
        };
      }).toList();

      return Success({
        'data': data,
        'pagination': {'total': data.length, 'page': 1, 'perPage': data.length},
      });
    } catch (e) {
      return Error(ServerException('Failed to list trash: $e'));
    }
  }

  /// GET /trash/{id} - View trashed document
  ///
  /// Response: Document metadata with deletion info
  Future<Result<Map<String, dynamic>, ApiGatewayException>> viewTrashDocument({
    required String id,
  }) async {
    try {
      final doc = await fakeServerDatabase.documents.findByUuid(id);
      if (doc == null) {
        return Error(ClientException('Document not found'));
      }

      if (doc['deleted_at'] == null) {
        return Error(ClientException('Document is not in trash'));
      }

      return Success({
        'id': doc['id'],
        'uuid': doc['uuid'],
        'titulo': doc['titulo'],
        'nomePaciente': doc['nome_paciente'],
        'nomeMedico': doc['nome_medico'],
        'tipoDocumento': doc['tipo_documento'],
        'dataDocumento': doc['data_documento'],
        'createdAt': doc['created_at'],
        'deletedAt': doc['deleted_at'],
      });
    } catch (e) {
      return Error(ServerException('Failed to view trash document: $e'));
    }
  }

  /// POST /trash/{id}/restore - Restore document from trash
  ///
  /// Response: `{status: String (success | error), message: String?}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>>
  restoreTrashDocument({required String id}) async {
    try {
      final doc = await fakeServerDatabase.documents.findByUuid(id);
      if (doc == null) {
        return Error(ClientException('Document not found'));
      }

      if (doc['deleted_at'] == null) {
        return Error(ClientException('Document is not in trash'));
      }

      final docId = doc['id'] as int;
      await fakeServerDatabase.documents.restore(docId);

      return Success({'status': 'success', 'message': null});
    } catch (e) {
      return Error(ServerException('Failed to restore document: $e'));
    }
  }

  /// POST /trash/{id}/destroy - Permanently delete document
  ///
  /// Response: `{status: String (success | error), message: String?}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>>
  destroyTrashDocument({required String id}) async {
    try {
      final doc = await fakeServerDatabase.documents.findByUuid(id);
      if (doc == null) {
        return Error(ClientException('Document not found'));
      }

      if (doc['deleted_at'] == null) {
        return Error(
          ClientException(
            'Document must be in trash before permanent deletion',
          ),
        );
      }

      await fakeServerDatabase.documents.hardDeleteByUuid(id);

      return Success({'status': 'success', 'message': null});
    } catch (e) {
      return Error(ServerException('Failed to destroy document: $e'));
    }
  }
}
