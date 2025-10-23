part of 'fake_api_gateway.dart';

class _DocumentController {
  _DocumentController({
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

  /// POST /documents/upload - Upload document file(s)
  ///
  /// Data: `{arquivos: File[], titulo: String?, nomePaciente: String?, nomeMedico: String?, tipoDocumento: String?, dataDocumento: String? (YYYY-MM-DD)}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> uploadDocument({
    required Map<String, dynamic> data,
  }) async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ClientException('User not found'));
      }

      // In fake implementation, we don't handle actual file uploads
      // Just create document metadata
      final titulo = data['titulo'] as String? ?? 'Documento sem título';
      final nomePaciente = data['nomePaciente'] as String?;
      final nomeMedico = data['nomeMedico'] as String?;
      final tipoDocumento = data['tipoDocumento'] as String?;
      final dataDocumento = data['dataDocumento'] as String?;

      final uuid = _generateUuid();
      final userId = user['id'] as int;

      await fakeServerDatabase.documents.create({
        'uuid': uuid,
        'titulo': titulo,
        'nome_paciente': nomePaciente,
        'nome_medico': nomeMedico,
        'tipo_documento': tipoDocumento,
        'data_documento': dataDocumento,
        'processando_metadados': 0,
        'created_at': DateTime.now().toIso8601String(),
        'fk_id_usuario': userId,
      });

      return Success({'status': 'success', 'message': null});
    } catch (e) {
      return Error(ServerException('Failed to upload document: $e'));
    }
  }

  /// GET /documents - List all documents (paginated)
  ///
  /// Response: Paginated list with document metadata
  Future<Result<Map<String, dynamic>, ApiGatewayException>>
  listDocuments() async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ClientException('User not found'));
      }

      final userId = user['id'] as int;
      final docs = await fakeServerDatabase.documents.findByUser(userId);

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
      return Error(ServerException('Failed to list documents: $e'));
    }
  }

  /// GET /documents/categories - List pre-existing categories
  ///
  /// Response: `{data: {pacientes: String[], medicos: String[], tipos: String[], documentos: String[]}}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>>
  listCategories() async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ClientException('User not found'));
      }

      final userId = user['id'] as int;
      final docs = await fakeServerDatabase.documents.findByUser(userId);

      // Extract unique categories
      final pacientes = <String>{};
      final medicos = <String>{};
      final tipos = <String>{};
      final documentos = <String>{};

      for (final doc in docs) {
        if (doc['nome_paciente'] != null) {
          pacientes.add(doc['nome_paciente'] as String);
        }
        if (doc['nome_medico'] != null) {
          medicos.add(doc['nome_medico'] as String);
        }
        if (doc['tipo_documento'] != null) {
          tipos.add(doc['tipo_documento'] as String);
        }
        if (doc['titulo'] != null) {
          documentos.add(doc['titulo'] as String);
        }
      }

      return Success({
        'data': {
          'pacientes': pacientes.toList(),
          'medicos': medicos.toList(),
          'tipos': tipos.toList(),
          'documentos': documentos.toList(),
        },
      });
    } catch (e) {
      return Error(ServerException('Failed to list categories: $e'));
    }
  }

  /// GET /documents/{id} - View document and metadata
  ///
  /// Response: `{id: int, titulo: String, nomePaciente: String?, nomeMedico: String?, tipoDocumento: String?, dataDocumento: String? (YYYY-MM-DD), createdAt: String (YYYY-MM-DD), deletedAt: String? (YYYY-MM-DD), caminhoArquivo: String?}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> getDocument({
    required String id,
  }) async {
    try {
      final doc = await fakeServerDatabase.documents.findByUuid(id);
      if (doc == null) {
        return Error(ClientException('Document not found'));
      }

      if (doc['deleted_at'] != null) {
        return Error(ClientException('Document has been deleted'));
      }

      return Success({
        'id': doc['id'],
        'titulo': doc['titulo'],
        'nomePaciente': doc['nome_paciente'],
        'nomeMedico': doc['nome_medico'],
        'tipoDocumento': doc['tipo_documento'],
        'dataDocumento': doc['data_documento'],
        'createdAt': doc['created_at'],
        'deletedAt': doc['deleted_at'],
      });
    } catch (e) {
      return Error(ServerException('Failed to get document: $e'));
    }
  }

  /// PUT /documents/{id} - Edit document metadata
  ///
  /// Data: `{titulo: String?, nomePaciente: String?, nomeMedico: String?, tipoDocumento: String?, dataDocumento: String? (YYYY-MM-DD)}`
  ///
  /// Response: Updated document metadata
  Future<Result<Map<String, dynamic>, ApiGatewayException>> editMetadata({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final doc = await fakeServerDatabase.documents.findByUuid(id);
      if (doc == null) {
        return Error(ClientException('Document not found'));
      }

      if (doc['deleted_at'] != null) {
        return Error(ClientException('Cannot edit deleted document'));
      }

      final updates = <String, dynamic>{};
      if (data.containsKey('titulo')) {
        updates['titulo'] = data['titulo'];
      }
      if (data.containsKey('nomePaciente')) {
        updates['nome_paciente'] = data['nomePaciente'];
      }
      if (data.containsKey('nomeMedico')) {
        updates['nome_medico'] = data['nomeMedico'];
      }
      if (data.containsKey('tipoDocumento')) {
        updates['tipo_documento'] = data['tipoDocumento'];
      }
      if (data.containsKey('dataDocumento')) {
        updates['data_documento'] = data['dataDocumento'];
      }

      await fakeServerDatabase.documents.updateByUuid(id, updates);

      // Fetch updated document
      final updatedDoc = await fakeServerDatabase.documents.findByUuid(id);

      return Success({
        'id': updatedDoc!['id'],
        'titulo': updatedDoc['titulo'],
        'nomePaciente': updatedDoc['nome_paciente'],
        'nomeMedico': updatedDoc['nome_medico'],
        'tipoDocumento': updatedDoc['tipo_documento'],
        'dataDocumento': updatedDoc['data_documento'],
        'createdAt': updatedDoc['created_at'],
      });
    } catch (e) {
      return Error(ServerException('Failed to edit document metadata: $e'));
    }
  }

  /// DELETE /documents/{id} - Move document to trash
  ///
  /// Response: `{message: String, dataExclusao: String (YYYY-MM-DD)}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> deleteDocument({
    required String id,
  }) async {
    try {
      final doc = await fakeServerDatabase.documents.findByUuid(id);
      if (doc == null) {
        return Error(ClientException('Document not found'));
      }

      if (doc['deleted_at'] != null) {
        return Error(ClientException('Document already deleted'));
      }

      final now = DateTime.now();
      await fakeServerDatabase.documents.updateByUuid(id, {
        'deleted_at': now.toIso8601String(),
      });

      return Success({
        'message': 'Document moved to trash',
        'dataExclusao': _formatDate(now),
      });
    } catch (e) {
      return Error(ServerException('Failed to delete document: $e'));
    }
  }

  /// GET /documents/{id}/download - Download and/or print document
  ///
  /// Response: `{arquivoBase64: String?, linkDownload: String?}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> downloadDocument({
    required String id,
  }) async {
    try {
      final doc = await fakeServerDatabase.documents.findByUuid(id);
      if (doc == null) {
        return Error(ClientException('Document not found'));
      }

      if (doc['deleted_at'] != null) {
        return Error(ClientException('Cannot download deleted document'));
      }

      // In fake implementation, return a fake base64 encoded string
      return Success({
        'arquivoBase64': 'ZmFrZV9kb2N1bWVudF9jb250ZW50',
        'linkDownload': null,
      });
    } catch (e) {
      return Error(ServerException('Failed to download document: $e'));
    }
  }

  /// Generate a UUID for documents
  String _generateUuid() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode;
    return 'doc_${timestamp}_$random';
  }

  /// Format DateTime to YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
