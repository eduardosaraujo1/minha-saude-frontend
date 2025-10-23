part of 'fake_api_gateway.dart';

class __TrashController {
  __TrashController({
    required this.fakeServerDatabase,
    required this.fakeServerCacheEngine,
    required this.fakeServerFileStorage,
  });
  final FakeServerCacheEngine fakeServerCacheEngine;
  final FakeServerDatabase fakeServerDatabase;
  final FakeServerFileStorage fakeServerFileStorage;

  /// GET /trash - List documents in trash (paginated)
  ///
  /// Query params: `{}`
  ///
  /// Response: Paginated list with trash documents
  static const String listTrash = '/trash';
  // Implementation: do NOT use pagination, just return all trashed documents

  /// GET /trash/{id} - View trashed document
  ///
  /// Response: Document metadata with deletion info
  static String viewTrashDocument(String id) => '/trash/$id';

  /// POST /trash/{id}/restore - Restore document from trash
  ///
  /// Data: `{}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static String restoreTrashDocument(String id) => '/trash/$id/restore';

  /// POST /trash/{id}/destroy - Permanently delete document
  ///
  /// Data: `{}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static String destroyTrashDocument(String id) => '/trash/$id/destroy';
}
