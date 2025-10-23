/// API routes dictionary for all endpoints
///
/// All dates follow 'YYYY-MM-DD' format
/// Phone numbers: ########### (10-11 digits, no country code)
abstract class GatewayRoutes {
  // ========== Authentication Routes ==========

  /// POST /auth/login/google - Login with Google
  ///
  /// Data: `{tokenOauth: String}`
  ///
  /// Response: `{isRegistered: bool, sessionToken: String?, registerToken: String?}`
  static const String loginGoogle = '/auth/login/google';

  /// POST /auth/login/email - Login with Email
  ///
  /// Data: `{email: String, codigoEmail: String}`
  ///
  /// Response: `{isRegistered: bool, sessionToken: String?, registerToken: String?}`
  static const String loginEmail = '/auth/login/email';

  /// POST /auth/register - Register a new user
  ///
  /// Data: `{user: {nome: String, cpf: String, dataNascimento: String (YYYY-MM-DD), telefone: String?}, registerToken: String}`
  ///
  /// Response: `{status: String (success | error), sessionToken: String?}`
  static const String registerUser = '/auth/register';

  /// POST /auth/logout - Invalidate current token
  ///
  /// Data: `{}`
  ///
  /// Response: `{status: String (success | error)}`
  static const String logout = '/auth/logout';

  /// POST /auth/send-email - Send email verification code for login
  ///
  /// Data: `{email: String}`
  ///
  /// Response: `{status: String (success | error)}`
  static const String sendEmail = '/auth/send-email';

  // ========== User/Profile Routes ==========

  /// GET /profile - Get user profile data
  ///
  /// Response: `{id: int, nome: String, cpf: String, email: String, telefone: String?, dataNascimento: String (YYYY-MM-DD), metodoAutenticacao: String (email | google)}`
  static const String getUserProfile = '/profile';

  /// PUT /profile/name - Edit user name
  ///
  /// Data: `{nome: String}`
  ///
  /// Response: `{id: int, nome: String}`
  static const String editName = '/profile/name';

  /// PUT /profile/birthdate - Edit user birthdate
  ///
  /// Data: `{dataNascimento: String (YYYY-MM-DD)}`
  ///
  /// Response: `{id: int, dataNascimento: String (YYYY-MM-DD)}`
  static const String editBirthdate = '/profile/birthdate';

  /// PUT /profile/phone - Edit phone number (requires SMS verification)
  ///
  /// Data: `{telefone: String, codigoSms: String}`
  ///
  /// Response: `{id: int, telefone: String}`
  static const String editPhone = '/profile/phone';

  /// POST /profile/phone/verify - Verify SMS code sent to phone
  ///
  /// Data: `{telefone: String, codigo: String}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static const String verifyPhoneCode = '/profile/phone/verify';

  /// POST /profile/phone/send-sms - Send SMS verification code
  ///
  /// Data: `{telefone: String}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static const String sendPhoneSms = '/profile/phone/send-sms';

  /// POST /profile/google/link - Link Google account
  ///
  /// Data: `{tokenOauth: String}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static const String linkGoogleAccount = '/profile/google/link';

  /// DELETE /profile - Schedule account deletion
  ///
  /// Data: `{authType: String (email | google), auth: {email: String?, codigoEmail: String?, tokenOauth: String?}}`
  ///
  /// Response: `{status: String (success | error)}`
  static const String deleteAccount = '/profile';

  // ========== Document Routes ==========

  /// POST /documents/upload - Upload document file(s)
  ///
  /// Data: `{arquivos: File[], titulo: String?, nomePaciente: String?, nomeMedico: String?, tipoDocumento: String?, dataDocumento: String? (YYYY-MM-DD)}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static const String uploadDocument = '/documents/upload';

  /// GET /documents - List all documents (paginated)
  ///
  /// Query params: `{page: int?, perPage: int?}`
  ///
  /// Response: Paginated list with document metadata
  static const String listDocuments = '/documents';

  /// GET /documents/categories - List pre-existing categories
  ///
  /// Query params: `{page: int?, perPage: int?}`
  ///
  /// Response: `{data: {pacientes: String[], medicos: String[], tipos: String[], documentos: String[]}}`
  static const String listCategories = '/documents/categories';

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

  // ========== Export Routes ==========

  /// POST /export/generate - Generate data export
  ///
  /// Data: `{}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static const String generateExport = '/export/generate';

  // ========== Trash Routes ==========

  /// GET /trash - List documents in trash (paginated)
  ///
  /// Query params: `{page: int?, perPage: int?}`
  ///
  /// Response: Paginated list with trash documents
  static const String listTrash = '/trash';

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

  // ========== Share Routes ==========

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

  /// GET /shares/{code} - View share code details
  ///
  /// Response: `{codigo: String, primeiroUsoEm: String? (YYYY-MM-DD), documentos: [{id: int, titulo: String}]}`
  static String getShareDetails(String code) => '/shares/$code';

  /// DELETE /shares/{code} - Invalidate share code
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static String deleteShare(String code) => '/shares/$code';
}
