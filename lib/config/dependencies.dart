import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../app/data/repositories/session/session_repository.dart';
import '../app/domain/actions/auth/logout.dart';
import '../app/domain/actions/auth/register_action.dart';
import '../app/data/services/file_system_service/file_system_service_impl.dart';
import '../app/data/services/api/auth/auth_api_client_impl.dart';
import '../app/data/services/api/document/document_api_client.dart';
import '../app/data/services/cache_database/cache_database.dart';
import '../app/data/services/api/http_client.dart';
import '../app/data/services/cache_database/cache_database_impl.dart';
import '../app/data/services/api/document/document_api_client_impl.dart';
import '../app/data/services/api/document/fake_document_api_client.dart';
import '../app/data/services/file_system_service/file_system_service.dart';
import '../app/ui/core/theme_provider.dart';
import '../app/domain/actions/auth/login_with_google.dart';
import '../app/data/repositories/document/document_repository_impl.dart';
import '../app/data/repositories/document/document_repository.dart';
import '../app/data/repositories/auth/auth_repository.dart';
import '../app/data/services/api/auth/fake_auth_api_client.dart';
import '../app/data/services/api/auth/auth_api_client.dart';
import '../app/data/services/doc_scanner/document_scanner.dart';
import '../app/data/services/google/google_service.dart';
import '../app/data/services/secure_storage/secure_storage.dart';
import 'environment.dart';

final _getIt = GetIt.instance;

Future<void> _registerDependenciesShared() async {
  _getIt.registerSingleton<ThemeProvider>(ThemeProvider());
}

Future<void> registerDependenciesDev({
  bool mockGoogle = false,
  bool mockApiClient = false,
  bool mockScanner = false,
  bool mockSecureStorage = false,
}) async {
  await _registerDependenciesShared();

  // Services
  _getIt.registerSingleton<SecureStorage>(
    mockSecureStorage ? SecureStorageFake() : SecureStorageImpl(),
  );
  _getIt.registerSingleton<DocumentScanner>(
    mockScanner ? FakeDocumentScanner() : DocumentScannerImpl(),
  );
  _getIt.registerSingleton<GoogleService>(
    mockGoogle ? GoogleServiceFake() : GoogleServiceImpl(GoogleSignIn.instance),
  );
  _getIt.registerSingleton<HttpClient>(HttpClient(baseUrl: Environment.apiUrl));
  _getIt.registerSingleton<AuthApiClient>(
    mockApiClient
        ? FakeAuthApiClient()
        : AuthApiClientImpl(_getIt<HttpClient>()),
  );
  _getIt.registerSingleton<DocumentApiClient>(
    mockApiClient
        ? FakeDocumentApiClient()
        : DocumentApiClientImpl(_getIt<HttpClient>()),
  );
  _getIt.registerSingleton<CacheDatabase>(CacheDatabaseImpl());
  _getIt.registerSingleton<FileSystemService>(FileSystemServiceImpl());

  // Repositories
  _getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      googleService: _getIt<GoogleService>(),
      apiClient: _getIt<AuthApiClient>(),
    ),
  );
  _getIt.registerSingleton<SessionRepository>(
    SessionRepositoryImpl(
      secureStorage: _getIt<SecureStorage>(), //
    ),
  );
  _getIt.registerSingleton<DocumentRepository>(
    DocumentRepositoryImpl(
      _getIt<DocumentApiClient>(),
      _getIt<CacheDatabase>(),
      _getIt<DocumentScanner>(),
      _getIt<FileSystemService>(),
    ),
  );

  // Actions
  _getIt.registerSingleton<LoginWithGoogle>(
    LoginWithGoogle(
      authRepository: _getIt<AuthRepository>(),
      sessionRepository: _getIt<SessionRepository>(),
    ),
  );
  _getIt.registerSingleton<Logout>(
    Logout(
      authRepository: _getIt<AuthRepository>(),
      sessionRepository: _getIt<SessionRepository>(),
      documentRepository: _getIt<DocumentRepository>(),
    ),
  );
  _getIt.registerSingleton<RegisterAction>(
    RegisterAction(
      sessionRepository: _getIt<SessionRepository>(),
      authRepository: _getIt<AuthRepository>(),
    ),
  );

  // Binds
  _getIt<HttpClient>().authHeaderProvider = () async {
    final token = await _getIt<SessionRepository>().getAuthToken();
    final t = token.tryGetSuccess();

    if (t == null) {
      return null;
    }

    return t;
  };
}

Future<void> registerDependenciesProd() async {
  // WIP
}
