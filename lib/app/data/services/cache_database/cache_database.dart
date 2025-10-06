import 'package:multiple_result/multiple_result.dart';

import 'models/document_db_model.dart';

/// This service wraps SQLite database, currently it's used for ensuring offline access of Documents.
/// It should be able to store document metadata and retreive when needed.
/// It must also have a clear method called when user logs out to prevent data leakage.
abstract class CacheDatabase {
  /// Initialize the database. Must be called before any other operations.
  Future<void> init();

  /// Clear all data from the database (used on logout)
  Future<Result<void, Exception>> clear();

  /// Add a document to the local database, or update it if it already exists (by UUID).
  /// By default, fills cachedAt with current time
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
  });

  /// Get all documents from the local database
  Future<Result<List<DocumentDbModel>, Exception>> listDocuments();

  /// Get a single document by its UUID
  Future<Result<DocumentDbModel?, Exception>> getDocument(String uuid);

  /// Move document to trash (deleted_at field) by its UUID
  Future<Result<void, Exception>> trashDocument(String uuid);

  /// Remove a document by its UUID
  Future<Result<void, Exception>> removeDocument(String uuid);
}
