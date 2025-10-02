import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/config/environment.dart';

import '../../app/data/repositories/document_repository.dart';
import '../../app/data/repositories/document_upload_repository.dart';
import '../../app/data/repositories/profile_repository.dart';
import '../../app/data/repositories/auth/auth_repository.dart';
import '../../app/data/services/api/api_client.dart';
import '../../app/data/services/doc_scanner/document_scanner.dart';
import '../../app/data/services/google/google_service.dart';
import '../../app/data/services/secure_storage/secure_storage.dart';
import 'dependencies.dart';

class DevelopmentDependencies implements Dependencies {
  DevelopmentDependencies({
    required this.mockGoogle,
    required this.mockApiClient,
    required this.mockScanner,
    required this.mockSecureStorage,
  });

  final bool mockGoogle;
  final bool mockApiClient;
  final bool mockScanner;
  final bool mockSecureStorage;

  final _getIt = GetIt.I;

  @override
  Future<void> register() async {
    // Services
    _getIt.registerSingleton<SecureStorage>(
      mockSecureStorage ? SecureStorageFake() : SecureStorageImpl(),
    );
    _getIt.registerSingleton<DocumentScanner>(
      mockScanner ? DocumentScannerFake() : DocumentScannerImpl(),
    );
    _getIt.registerSingleton<GoogleService>(
      mockGoogle
          ? GoogleServiceFake()
          : GoogleServiceImpl(GoogleSignIn.instance),
    );
    _getIt.registerSingleton<ApiClient>(
      mockApiClient
          ? FakeApiClient()
          : ApiClientImpl(Dio(), Environment.apiUrl),
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

  @override
  Future<void> bind() async {
    // Fill if needed
  }
}
