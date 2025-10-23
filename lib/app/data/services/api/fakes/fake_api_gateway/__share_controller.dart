part of 'fake_api_gateway.dart';

class __ShareController {
  __ShareController({
    required this.fakeServerDatabase,
    required this.fakeServerCacheEngine,
    required this.fakeServerFileStorage,
  });
  final FakeServerCacheEngine fakeServerCacheEngine;
  final FakeServerDatabase fakeServerDatabase;
  final FakeServerFileStorage fakeServerFileStorage;

  /// POST /shares - Create document share code
  ///
  /// Data: `{idsDocumentos: int[]}`
  ///
  /// Response: `{codigo: String}`
  static const String createShare = '/shares';

  /// GET /shares - List active share codes (paginated)
  ///
  /// Query params: `{page: int?, perPage: int?}`
  ///
  /// Response: Paginated list of share codes
  static const String listShares = '/shares';
  // Implementation: do NOT use pagination, just return all share codes

  /// GET /shares/{code} - View share code details
  ///
  /// Response: `{codigo: String, primeiroUsoEm: String? (YYYY-MM-DD), documentos: [{id: int, titulo: String}]}`
  static String getShareDetails(String code) => '/shares/$code';

  /// DELETE /shares/{code} - Invalidate share code
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static String deleteShare(String code) => '/shares/$code';
}
