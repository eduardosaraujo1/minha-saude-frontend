import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/document/document.dart';

/// Repository interface for managing documents, including uploading, fetching, editing, and deleting documents. It abstracts the underlying data sources, such as remote APIs and local databases.
///
/// ### Features
///
/// 1. It allows users to upload documents either by picking files from the device or scanning them using document scanner.
/// 2. it also interfaces the document metadata management, allowing users to associate information with each document, such as title, type, associated patient, and date. This association also includes the ability to update the metadata both locally and remotely.
/// Note that document deletion is a soft delete, where permanent deletion is not performed. Deleted documents can still be seen in the TrashRepository and restored if needed.
/// 3. it has support for offline, replicating reads and writes to both a local database and the remote source, ensuring data consistency and availability. This is also done through storing a local cache of document files permanently, identifying them through UUID.
///
/// Finally, it has an in-memory caching policy to optimize performance and reduce redundant network calls, with the ability to force refresh data from the remote source when needed.
///
/// ### Caching Policy
///
/// The caching policy works as follows:
/// - **Document List**: Cached in memory after the first fetch with 1 hour expiration period. Can be force refreshed.
/// - **Document Upload**: Uploads to remote source first, and if successful, replicates the change in the local database and adds the new document to the in-memory cache, which does not change the 1 hour expiration timer.
/// - **Document Get**: Checks in-memory cache first, then remote source, and finally as a fallback the local source. Can be force refreshed. When the remote source is fetched, the database cache is updated , but the in-memory cache is not.
/// - **Document Download**: Checks local file source first, then remote source. If the remote source is fetched, the local file cache is updated. The local file does not expire.
/// - **Document Update**: Updates remote source and, when remote is successful, the local database. Then it patches the in-memory cache by either replacing the existing one or adding it if it did not exist.
/// - **Document Delete**: Calls remote source and, if successful, the local database. Then it patches the in-memory cache without reseting the expiration timer.
abstract class DocumentRepository extends ChangeNotifier {
  /// Get document file from file picker
  Future<Result<File, Exception>> pickDocumentFile();

  /// Get document file from scanner
  Future<Result<File, Exception>> scanDocumentFile();

  /// Upload document file with metadata to server
  ///
  /// Also stores document metadata locally through LocalDatabase, only if the server
  /// upload is successful.
  Future<Result<Document, Exception>> uploadDocument(
    File file, {
    required String titulo,
    required String? paciente,
    required String? tipo,
    required String? medico,
    required DateTime? dataDocumento,
  });

  /// List available document metadata stored in the server
  ///
  /// If server is unreachable, falls back to local database
  ///
  /// Stores cache in memory for faster subsequent access
  ///
  /// If [forceRefresh] is true, ignores local cache and fetches from remote source
  ///
  /// Returns [Result] with [List<Document>] on success or [Exception] on failure
  Future<Result<List<Document>, Exception>> listDocuments({
    bool forceRefresh = false,
  });

  /// Get single document by id with metadata
  ///
  /// Returns [Result] with [Document] on success or [Exception] on failure
  Future<Result<Document, Exception>> getDocumentMeta(
    String uuid, {
    bool forceRefresh = false,
  });

  /// Get single document by id with metadata
  ///
  /// Caches only the most recent file accessed in memory
  Future<Result<File, Exception>> getDocumentFile(String uuid);

  /// Edits document metadata on server and replicates update on local cache
  ///
  /// Returns updated [Document] on success or [Exception] on failure
  Future<Result<Document, Exception>> updateDocument(
    String uuid, {
    String? titulo,
    String? paciente,
    String? tipo,
    String? medico,
    DateTime? dataDocumento,
  });

  /// Move document to trash on server and update local cache
  ///
  /// Document is not deleted permanently, but marked as deleted
  /// and can be restored from TrashRepository
  Future<Result<void, Exception>> moveToTrash(String uuid);

  /// Clears all cache, including memory, saved document files and local database
  ///
  /// Necessary for user logout
  Future<void> clearCache();
}
