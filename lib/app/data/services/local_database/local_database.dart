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
    required String titulo,
    required String paciente,
    required String medico,
    required String tipo,
    required DateTime dataDocumento,
    required DateTime dataAdicao,
    String? localFilePath,
  });

  /// Remove a document by its UUID
  Future<void> removeDocument(String uuid);

  /// Update a document's information
  Future<void> updateDocument({
    required String uuid,
    String? titulo,
    String? paciente,
    String? medico,
    String? tipo,
    DateTime? dataDocumento,
    DateTime? dataAdicao,
    String? localFilePath,
  });

  /// Get all documents from the local database
  Future<List<Document>> getDocuments();

  /// Get a single document by its UUID
  Future<Document?> getDocument(String uuid);

  /// Check if a document exists locally by UUID
  Future<bool> hasDocument(String uuid);

  /// Update the local file path for a document (after downloading)
  Future<void> updateLocalFilePath(String uuid, String? filePath);
}
