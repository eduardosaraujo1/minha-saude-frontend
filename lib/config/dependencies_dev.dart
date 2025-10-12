import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../app/data/repositories/profile/profile_repository.dart';
import '../app/data/repositories/profile/profile_repository_impl.dart';
import '../app/data/repositories/session/session_repository.dart';
import '../app/data/services/api/fake_server_persistent_storage.dart';
import '../app/data/services/api/profile/fake_profile_api_client.dart';
import '../app/data/services/api/profile/profile_api_client.dart';
import '../app/data/services/api/profile/profile_api_client_impl.dart';
import '../app/domain/actions/auth/logout_action.dart';
import '../app/domain/actions/auth/register_action.dart';
import '../app/data/services/local/file_system_service/file_system_service_impl.dart';
import '../app/data/services/api/auth/auth_api_client_impl.dart';
import '../app/data/services/api/document/document_api_client.dart';
import '../app/data/services/local/cache_database/cache_database.dart';
import '../app/data/services/api/http_client.dart';
import '../app/data/services/local/cache_database/cache_database_impl.dart';
import '../app/data/services/api/document/document_api_client_impl.dart';
import '../app/data/services/api/document/fake_document_api_client.dart';
import '../app/data/services/local/file_system_service/file_system_service.dart';
import '../app/domain/actions/settings/delete_user_action.dart';
import '../app/domain/actions/settings/request_export_action.dart';
import '../app/ui/core/theme_provider.dart';
import '../app/domain/actions/auth/login_with_google.dart';
import '../app/data/repositories/document/document_repository_impl.dart';
import '../app/data/repositories/document/document_repository.dart';
import '../app/data/repositories/auth/auth_repository.dart';
import '../app/data/services/api/auth/fake_auth_api_client.dart';
import '../app/data/services/api/auth/auth_api_client.dart';
import '../app/data/services/doc_scanner/document_scanner.dart';
import '../app/data/services/google/google_service.dart';
import '../app/data/services/local/secure_storage/secure_storage.dart';
import 'environment.dart';

final _getIt = GetIt.instance;

Future<void> setup({
  bool mockGoogle = false,
  bool mockApiClient = false,
  bool mockScanner = false,
  bool mockSecureStorage = false,
}) async {
  // TODO: remove this when real API is created
  _getIt.registerSingleton<FakeServerPersistentStorage>(
    FakeServerPersistentStorage(),
  );
  // Core
  _getIt.registerSingleton<ThemeController>(ThemeController());

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
  _getIt.registerSingleton<CacheDatabase>(CacheDatabaseImpl());
  _getIt.registerSingleton<FileSystemService>(FileSystemServiceImpl());

  if (mockApiClient) {
    _getIt.registerSingleton<AuthApiClient>(
      FakeAuthApiClient(
        fakePersistentStorage: _getIt<FakeServerPersistentStorage>(),
      ),
    );
    _getIt.registerSingleton<DocumentApiClient>(FakeDocumentApiClient());
    _getIt.registerSingleton<ProfileApiClient>(
      FakeProfileApiClient(
        fakePersistentStorage: _getIt<FakeServerPersistentStorage>(),
      ),
    );
  } else {
    _getIt.registerSingleton<AuthApiClient>(
      AuthApiClientImpl(_getIt<HttpClient>()),
    );
    _getIt.registerSingleton<DocumentApiClient>(
      DocumentApiClientImpl(_getIt<HttpClient>()),
    );
    _getIt.registerSingleton<ProfileApiClient>(
      ProfileApiClientImpl(_getIt<HttpClient>()),
    );
  }

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
  _getIt.registerSingleton<ProfileRepository>(
    ProfileRepositoryImpl(
      profileApiClient: _getIt<ProfileApiClient>(), //
    ),
  );

  // Actions
  _getIt.registerSingleton<LoginWithGoogle>(
    LoginWithGoogle(
      authRepository: _getIt<AuthRepository>(),
      sessionRepository: _getIt<SessionRepository>(),
    ),
  );
  _getIt.registerSingleton<LogoutAction>(
    LogoutAction(
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
  _getIt.registerSingleton<DeleteUserAction>(
    DeleteUserAction(
      profileRepository: _getIt<ProfileRepository>(),
      sessionRepository: _getIt<SessionRepository>(),
    ),
  );
  _getIt.registerSingleton<RequestExportAction>(
    RequestExportAction(profileRepository: _getIt<ProfileRepository>()),
  );

  // Post-register configuration
  await _getIt<CacheDatabase>().init();

  final docApiClient = _getIt<DocumentApiClient>();
  if (docApiClient is FakeDocumentApiClient) {
    await docApiClient.populateLocalArrayWithDatabaseData(
      _getIt<CacheDatabase>(),
    );
  }

  _getIt<HttpClient>().authHeaderProvider = () async {
    final token = await _getIt<SessionRepository>().getAuthToken();
    final t = token.tryGetSuccess();

    if (t == null) {
      return null;
    }

    return t;
  };
}
