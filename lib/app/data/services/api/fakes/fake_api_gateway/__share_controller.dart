part of 'fake_api_gateway.dart';

class _ShareController {
  _ShareController({
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

  /// POST /shares - Create document share code
  ///
  /// Data: `{idsDocumentos: int[]}`
  ///
  /// Response: `{codigo: String}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> createShare({
    required Map<String, dynamic> data,
  }) async {
    try {
      final idsDocumentos = data['idsDocumentos'] as List<dynamic>?;
      if (idsDocumentos == null || idsDocumentos.isEmpty) {
        return Error(
          ApiGatewayException('Missing idsDocumentos', statusCode: 422),
        );
      }

      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ApiGatewayException('User not found', statusCode: 404));
      }

      final userId = user['id'] as int;
      final codigo = _generateShareCode();

      // Create share record
      final shareId = await fakeServerDatabase.shares.create({
        'codigo': codigo,
        'data_primeiro_uso': null,
        'expirado': 0,
        'created_at': DateTime.now().toIso8601String(),
        'fk_id_usuario': userId,
      });

      // Link documents to share
      for (final docId in idsDocumentos) {
        await fakeServerDatabase.shares.addDocument(shareId, docId as int);
      }

      return Success({'codigo': codigo});
    } catch (e) {
      return Error(
        ApiGatewayException('Failed to create share: $e', statusCode: 500),
      );
    }
  }

  /// GET /shares - List active share codes (paginated)
  ///
  /// Response: Paginated list of share codes
  Future<Result<Map<String, dynamic>, ApiGatewayException>> listShares() async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ApiGatewayException('User not found', statusCode: 404));
      }

      final userId = user['id'] as int;
      final shares = await fakeServerDatabase.shares.findByUser(userId);

      final data = shares.map((share) {
        return {
          'id': share['id'],
          'codigo': share['codigo'],
          'dataprimeiroUso': share['data_primeiro_uso'],
          'expirado': share['expirado'] == 1,
          'createdAt': share['created_at'],
        };
      }).toList();

      return Success({
        'data': data,
        'pagination': {'total': data.length, 'page': 1, 'perPage': data.length},
      });
    } catch (e) {
      return Error(
        ApiGatewayException('Failed to list shares: $e', statusCode: 500),
      );
    }
  }

  /// GET /shares/{code} - View share code details
  ///
  /// Response: `{codigo: String, primeiroUsoEm: String? (YYYY-MM-DD), documentos: [{id: int, titulo: String}]}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> getShareDetails({
    required String code,
  }) async {
    try {
      final share = await fakeServerDatabase.shares.findByCode(code);
      if (share == null) {
        return Error(
          ApiGatewayException('Share code not found', statusCode: 404),
        );
      }

      final shareId = share['id'] as int;
      final docs = await fakeServerDatabase.shares.getDocuments(shareId);

      final documentos = docs.map((doc) {
        return {'id': doc['id'], 'titulo': doc['titulo']};
      }).toList();

      return Success({
        'codigo': share['codigo'],
        'primeiroUsoEm': share['data_primeiro_uso'],
        'documentos': documentos,
      });
    } catch (e) {
      return Error(
        ApiGatewayException('Failed to get share details: $e', statusCode: 500),
      );
    }
  }

  /// DELETE /shares/{code} - Invalidate share code
  ///
  /// Response: `{status: String (success | error), message: String?}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> deleteShare({
    required String code,
  }) async {
    try {
      final share = await fakeServerDatabase.shares.findByCode(code);
      if (share == null) {
        return Error(
          ApiGatewayException('Share code not found', statusCode: 404),
        );
      }

      await fakeServerDatabase.shares.deleteByCode(code);

      return Success({'status': 'success', 'message': null});
    } catch (e) {
      return Error(
        ApiGatewayException('Failed to delete share: $e', statusCode: 500),
      );
    }
  }

  /// Generate a random share code
  String _generateShareCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode;
    return 'SHARE${timestamp.toString().substring(7)}${random.toString().substring(0, 4)}';
  }
}
