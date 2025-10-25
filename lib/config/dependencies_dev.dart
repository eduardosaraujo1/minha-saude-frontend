import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../app/data/repositories/auth/auth_repository.dart';
import '../app/data/repositories/document/cache/document_file_cache_store.dart';
import '../app/data/repositories/document/cache/document_list_cache_store.dart';
import '../app/data/repositories/document/document_repository.dart';
import '../app/data/repositories/document/document_repository_impl.dart';
import '../app/data/repositories/profile/profile_repository.dart';
import '../app/data/repositories/profile/profile_repository_impl.dart';
import '../app/data/repositories/session/session_repository.dart';
import '../app/data/repositories/trash/trash_repository.dart';
import '../app/data/repositories/trash/trash_repository_impl.dart';
import '../app/data/services/api/clients/auth/auth_api_client.dart';
import '../app/data/services/api/clients/auth/fake_auth_api_client.dart';
import '../app/data/services/api/clients/document/document_api_client.dart';
import '../app/data/services/api/clients/document/fake_document_api_client.dart';
import '../app/data/services/api/clients/profile/fake_profile_api_client.dart';
import '../app/data/services/api/clients/profile/profile_api_client.dart';
import '../app/data/services/api/clients/trash/fake_trash_api_client.dart';
import '../app/data/services/api/clients/trash/trash_api_client.dart';
import '../app/data/services/api/fake/fake_api_gateway/fake_api_gateway.dart';
import '../app/data/services/api/fake/fake_server_cache_engine.dart';
import '../app/data/services/api/fake/fake_server_database.dart';
import '../app/data/services/api/fake/fake_server_file_storage.dart';
import '../app/data/services/api/gateway/api_gateway.dart';
import '../app/data/services/local/doc_scanner/document_scanner.dart';
import '../app/data/services/google/google_service.dart';
import '../app/data/services/local/cache_database/cache_database.dart';
import '../app/data/services/local/cache_database/cache_database_impl.dart';
import '../app/data/services/local/cache_database/fake_cache_database.dart';
import '../app/data/services/local/file_system_service/file_system_service.dart';
import '../app/data/services/local/file_system_service/file_system_service_impl.dart';
import '../app/data/services/local/secure_storage/secure_storage.dart';
import '../app/data/services/sqlite/sqlite_database.dart';
import '../app/domain/actions/auth/get_tos_action.dart';
import '../app/domain/actions/auth/logout_action.dart';
import '../app/domain/actions/auth/process_login_result_action.dart';
import '../app/domain/actions/auth/register_action.dart';
import '../app/domain/actions/settings/delete_user_action.dart';
import '../app/domain/actions/settings/request_export_action.dart';
import '../app/ui/core/theme_provider.dart';

final _getIt = GetIt.instance;

Future<void> setup({
  bool mockGoogle = false,
  bool mockServer = false,
  bool mockScanner = false,
  bool mockSecureStorage = false,
  bool mockCacheDb = false,
}) async {
  mockGoogle = mockGoogle || !(Platform.isAndroid || Platform.isIOS);
  mockCacheDb = mockCacheDb || !(Platform.isAndroid || Platform.isIOS);

  // Core
  _getIt.registerSingleton<ThemeController>(ThemeController());

  // Services
  _getIt.registerSingleton<SecureStorage>(
    mockSecureStorage ? SecureStorageFake() : SecureStorageImpl(),
  );
  _getIt.registerSingleton<DocumentScanner>(
    mockScanner ? FakeDocumentScanner() : DocumentScannerImpl(),
  );
  _getIt.registerSingleton<FileSystemService>(FileSystemServiceImpl());
  if (mockGoogle) {
    _getIt.registerSingleton<GoogleService>(GoogleServiceFake());
  } else {
    _getIt.registerSingleton<GoogleService>(
      GoogleServiceImpl(GoogleSignIn.instance),
    );
  }
  if (mockCacheDb) {
    _getIt.registerSingleton<CacheDatabase>(FakeCacheDatabase());
  } else {
    _getIt.registerSingleton<CacheDatabase>(
      CacheDatabaseImpl(sqliteDatabase: SqliteDatabase.forCacheDatabase()),
    );
  }

  _getIt.registerSingleton<DocumentListCacheStore>(DocumentListCacheStore());
  _getIt.registerSingleton<DocumentFileCacheStore>(DocumentFileCacheStore());

  // Register ApiGateway
  if (mockServer) {
    _getIt.registerSingleton<FakeServerCacheEngine>(FakeServerCacheEngine());
    _getIt.registerSingleton<FakeServerDatabase>(
      FakeServerDatabase(
        sqliteDatabase: SqliteDatabase.forFakeServerDatabase(),
      ),
    );
    _getIt.registerSingleton<FakeServerFileStorage>(FakeServerFileStorage());
    _getIt.registerSingleton<ApiGateway>(
      FakeApiGateway(
        fakeServerCacheEngine: _getIt<FakeServerCacheEngine>(),
        fakeServerDatabase: _getIt<FakeServerDatabase>(),
        fakeServerFileStorage: _getIt<FakeServerFileStorage>(),
      ),
    );
  } else {
    _getIt.registerSingleton<ApiGateway>(ApiGatewayImpl());
  }

  if (mockServer) {
    _getIt.registerSingleton<AuthApiClient>(
      FakeAuthApiClient(
        fakeServerDatabase: _getIt<FakeServerDatabase>(),
        fakeServerCacheEngine: _getIt<FakeServerCacheEngine>(),
      ),
    );
    _getIt.registerSingleton<DocumentApiClient>(
      FakeDocumentApiClient(
        fakeServerDatabase: _getIt<FakeServerDatabase>(),
        fakeServerFileStorage: _getIt<FakeServerFileStorage>(),
      ),
    );
    _getIt.registerSingleton<TrashApiClient>(
      FakeTrashApiClient(
        fakeServerDatabase: _getIt<FakeServerDatabase>(),
        fakeServerFileStorage: _getIt<FakeServerFileStorage>(),
      ),
    );
    _getIt.registerSingleton<ProfileApiClient>(
      FakeProfileApiClient(
        fakeServerDatabase: _getIt<FakeServerDatabase>(),
        fakeServerCacheEngine: _getIt<FakeServerCacheEngine>(),
      ),
    );
  } else {
    // Register real implementation
    // TODO: Implement real API clients when backend is ready
    throw UnimplementedError('Real API clients not yet implemented');
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
      documentApiClient: _getIt<DocumentApiClient>(),
      documentScanner: _getIt<DocumentScanner>(),
      fileSystemService: _getIt<FileSystemService>(),
      localDatabase: _getIt<CacheDatabase>(),
      documentListCache: _getIt<DocumentListCacheStore>(),
      documentFileCache: _getIt<DocumentFileCacheStore>(),
    ),
  );
  _getIt.registerSingleton<ProfileRepository>(
    ProfileRepositoryImpl(
      profileApiClient: _getIt<ProfileApiClient>(), //
    ),
  );
  _getIt.registerSingleton<TrashRepository>(
    TrashRepositoryImpl(
      fileSystemService: _getIt<FileSystemService>(),
      localDatabase: _getIt<CacheDatabase>(),
      trashApiClient: _getIt<TrashApiClient>(),
    ),
  );

  // Actions
  _getIt.registerSingleton<ProcessLoginResultAction>(
    ProcessLoginResultAction(sessionRepository: _getIt<SessionRepository>()),
  );
  _getIt.registerSingleton<LogoutAction>(
    LogoutAction(
      authRepository: _getIt<AuthRepository>(),
      sessionRepository: _getIt<SessionRepository>(),
      documentRepository: _getIt<DocumentRepository>(),
      profileRepository: _getIt<ProfileRepository>(),
    ),
  );
  _getIt.registerSingleton<GetTosAction>(GetTosAction());
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

  if (mockServer) {
    // Initialize fake server storage
    await _getIt<FakeServerDatabase>().init();
    _getIt<FakeServerFileStorage>().initialize();
  } else {
    // Configure ApiGateway auth header provider
    _getIt<ApiGateway>().authHeaderProvider = () async {
      final token = await _getIt<SessionRepository>().getAuthToken();
      final t = token.tryGetSuccess();

      if (t == null) {
        return null;
      }

      return t;
    };
  }
}
