import 'package:minha_saude_frontend/app/data/services/local/cache_database/models/document_db_model.dart';
import 'package:multiple_result/multiple_result.dart';

import 'cache_database.dart';

/// In-memory implementation of CacheDatabase using a List for testing purposes.
/// Mimics the behavior of CacheDatabaseImpl without requiring SQLite.
class FakeCacheDatabase implements CacheDatabase {
  final List<DocumentDbModel> _documents = [];
  bool _initialized = false;

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'Database not initialized. Call init() before using the database.',
      );
    }
  }

  @override
  Future<void> init() async {
    _initialized = true;
  }

  @override
  Future<Result<void, Exception>> clear() async {
    try {
      _ensureInitialized();
      _documents.clear();
      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to clear database: $e'));
    }
  }

  @override
  Future<Result<DocumentDbModel, Exception>> upsertDocument(
    String uuid, {
    String? titulo,
    String? paciente,
    String? medico,
    String? tipo,
    DateTime? dataDocumento,
    required DateTime createdAt,
    DateTime? deletedAt,
    DateTime? cachedAt,
  }) async {
    try {
      _ensureInitialized();

      // Create document with cachedAt defaulting to now if not provided
      final document = DocumentDbModel(
        uuid: uuid,
        titulo: titulo,
        paciente: paciente,
        medico: medico,
        tipo: tipo,
        dataDocumento: dataDocumento,
        createdAt: createdAt,
        deletedAt: deletedAt,
        cachedAt: cachedAt ?? DateTime.now(),
      );

      // Remove existing document with same UUID (if exists)
      _documents.removeWhere((doc) => doc.uuid == uuid);

      // Add new/updated document
      _documents.add(document);

      return Success(document);
    } catch (e) {
      return Error(Exception('Failed to upsert document: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> removeDocument(String uuid) async {
    try {
      _ensureInitialized();

      final initialLength = _documents.length;
      _documents.removeWhere((doc) => doc.uuid == uuid);

      if (_documents.length == initialLength) {
        return Error(Exception('Document not found'));
      }

      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to remove document: $e'));
    }
  }

  @override
  Future<Result<List<DocumentDbModel>, Exception>> listDocuments() async {
    try {
      _ensureInitialized();

      // Sort by createdAt descending (newest first)
      final sortedDocuments = List<DocumentDbModel>.from(_documents)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Success(sortedDocuments);
    } catch (e) {
      return Error(Exception('Failed to list documents: $e'));
    }
  }

  @override
  Future<Result<DocumentDbModel?, Exception>> getDocument(String uuid) async {
    try {
      _ensureInitialized();

      final document = _documents.where((doc) => doc.uuid == uuid).firstOrNull;

      return Success(document);
    } catch (e) {
      return Error(Exception('Failed to get document: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> trashDocument(String uuid) async {
    try {
      _ensureInitialized();

      final index = _documents.indexWhere((doc) => doc.uuid == uuid);

      if (index == -1) {
        return Error(Exception('Document not found'));
      }

      // Create a new document with updated deletedAt timestamp
      final existingDoc = _documents[index];
      final updatedDoc = DocumentDbModel(
        uuid: existingDoc.uuid,
        titulo: existingDoc.titulo,
        paciente: existingDoc.paciente,
        medico: existingDoc.medico,
        tipo: existingDoc.tipo,
        dataDocumento: existingDoc.dataDocumento,
        createdAt: existingDoc.createdAt,
        deletedAt: DateTime.now(),
        cachedAt: existingDoc.cachedAt,
      );

      _documents[index] = updatedDoc;

      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to trash document: $e'));
    }
  }
}
