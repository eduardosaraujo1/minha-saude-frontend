import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'environment.dart';
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
    mockScanner ? DocumentScannerFake() : DocumentScannerImpl(),
  );
  _getIt.registerSingleton<GoogleService>(
    mockGoogle ? GoogleServiceFake() : GoogleServiceImpl(GoogleSignIn.instance),
  );
  _getIt.registerSingleton<AuthApiClient>(
    mockApiClient
        ? FakeAuthApiClient()
        : AuthApiClientImpl(Dio(), Environment.apiUrl),
  );

  // Repositories
  _getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      _getIt<SecureStorage>(),
      _getIt<GoogleService>(),
      _getIt<AuthApiClient>(),
    ),
  );
  _getIt.registerSingleton<DocumentRepository>(DocumentRepositoryImpl());

  _getIt.registerSingleton<LoginWithGoogle>(
    LoginWithGoogle(_getIt<AuthRepository>()),
  );
}

Future<void> registerDependenciesProd() async {
  // WIP
}
