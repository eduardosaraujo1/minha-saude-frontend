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

  /// POST /documents/upload - Upload document file(s)
  ///
  /// Data: `{arquivos: File[], titulo: String?, nomePaciente: String?, nomeMedico: String?, tipoDocumento: String?, dataDocumento: String? (YYYY-MM-DD)}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static const String uploadDocument = '/documents/upload';
  // Implementation: store file metadata in fakeServerDatabase and file content in fakeServerFileStorage

  /// GET /documents - List all documents (paginated)
  ///
  /// Query params: `{page: int?, perPage: int?}`
  ///
  /// Response: Paginated list with document metadata
  static const String listDocuments = '/documents';
  // Implementation: query all documents in metadata (no pagination)

  /// GET /documents/categories - List pre-existing categories
  ///
  /// Query params: `{page: int?, perPage: int?}`
  ///
  /// Response: `{data: {pacientes: String[], medicos: String[], tipos: String[], documentos: String[]}}`
  static const String listCategories = '/documents/categories';
  // Implementation: query all documents in metadata (no pagination)

  /// GET /documents/{id} - View document and metadata
  ///
  /// Response: `{id: int, titulo: String, nomePaciente: String?, nomeMedico: String?, tipoDocumento: String?, dataDocumento: String? (YYYY-MM-DD), createdAt: String (YYYY-MM-DD), deletedAt: String? (YYYY-MM-DD), caminhoArquivo: String?}`
  static String getDocument(String id) => '/documents/$id';

  /// PUT /documents/{id} - Edit document metadata
  ///
  /// Data: `{titulo: String?, nomePaciente: String?, nomeMedico: String?, tipoDocumento: String?, dataDocumento: String? (YYYY-MM-DD)}`
  ///
  /// Response: Updated document metadata
  static String editMetadata(String id) => '/documents/$id';

  /// DELETE /documents/{id} - Move document to trash
  ///
  /// Response: `{message: String, dataExclusao: String (YYYY-MM-DD)}`
  static String deleteDocument(String id) => '/documents/$id';

  /// GET /documents/{id}/download - Download and/or print document
  ///
  /// Response: `{arquivoBase64: String?, linkDownload: String?}`
  static String downloadDocument(String id) => '/documents/$id/download';
}
