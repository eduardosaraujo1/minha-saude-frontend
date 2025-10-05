import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/document/document.dart';

/// This service wraps SQLite database, currently it's used for ensuring offline access of Documents.
/// It should be able to store document metadata and retreive when needed.
/// It must also have a clear method called when user logs out to prevent data leakage.
abstract class LocalDatabase {
  /// Initialize the database. Must be called before any other operations.
  Future<void> init();

  /// Clear all data from the database (used on logout)
  Future<void> clear();

  /// Add a document to the local database
  Future<void> addDocument({
    required String uuid,
    String? titulo,
    String? paciente,
    String? medico,
    String? tipo,
    DateTime? dataDocumento,
    required DateTime createdAt,
    DateTime? deletedAt,
  });

  /// Remove a document by its UUID
  Future<Result<void, Exception>> removeDocument(String uuid);

  /// Update a document's information
  /// May be used to delete (soft delete) a document by setting deletedAt
  Future<Result<void, Exception>> updateDocument({
    required String uuid,
    String? titulo,
    String? paciente,
    String? medico,
    String? tipo,
    DateTime? dataDocumento,
    required DateTime createdAt,
  });

  /// Move document to trash (deleted_at field) by its UUID
  Future<Result<void, Exception>> trashDocument(String uuid);

  /// Get all documents from the local database
  Future<Result<List<Document>, Exception>> getDocuments();

  /// Get a single document by its UUID
  Future<Result<Document?, Exception>> getDocument(String uuid);

  /// Check if a document exists locally by UUID
  Future<bool> hasDocument(String uuid);
}
