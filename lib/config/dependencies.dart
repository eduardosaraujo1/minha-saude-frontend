import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'environment.dart';
import '../app/ui/core/themes/app_theme.dart';
import '../app/data/repositories/document_repository.dart';
import '../app/data/repositories/document_upload_repository.dart';
import '../app/data/repositories/profile_repository.dart';
import '../app/data/repositories/auth/auth_repository.dart';
import '../app/data/services/api/api_client.dart';
import '../app/data/services/doc_scanner/document_scanner.dart';
import '../app/data/services/google/google_service.dart';
import '../app/data/services/secure_storage/secure_storage.dart';

final _getIt = GetIt.instance;

Future<void> _registerDependenciesShared() async {
  _getIt.registerSingleton<AppTheme>(AppTheme());
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
    mockScanner ? DocumentScannerFake() : DocumentScannerImpl(),
  );
  _getIt.registerSingleton<GoogleService>(
    mockGoogle ? GoogleServiceFake() : GoogleServiceImpl(GoogleSignIn.instance),
  );
  _getIt.registerSingleton<ApiClient>(
    mockApiClient ? FakeApiClient() : ApiClientImpl(Dio(), Environment.apiUrl),
  );

  // Repositories
  _getIt.registerSingletonWithDependencies<AuthRepository>(
    () => AuthRepositoryImpl(
      _getIt<SecureStorage>(),
      _getIt<GoogleService>(),
      _getIt<ApiClient>(),
    ),
    dependsOn: [SecureStorage, GoogleService, ApiClient],
  );
  _getIt.registerSingleton<DocumentRepository>(DocumentRepository());
  _getIt.registerSingleton<ProfileRepository>(ProfileRepository());
  _getIt.registerSingletonWithDependencies<DocumentUploadRepository>(
    () => DocumentUploadRepository(_getIt<DocumentScanner>()),
    dependsOn: [DocumentScanner],
  );
}

Future<void> registerDependenciesProd() async {
  // WIP
}
