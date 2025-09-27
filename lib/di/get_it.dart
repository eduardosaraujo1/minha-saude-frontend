import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/services/auth_remote_service.dart';
import 'package:minha_saude_frontend/app/data/services/google_sign_in_service.dart';
import 'package:minha_saude_frontend/app/data/repositories/document_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/document_upload_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/token_repository.dart';
import 'package:minha_saude_frontend/app/data/services/api_client.dart';
import 'package:minha_saude_frontend/app/data/services/document_scanner.dart';
import 'package:minha_saude_frontend/app/data/services/secure_storage.dart';
import 'package:minha_saude_frontend/app/ui/core/themes/app_theme.dart';
import 'package:minha_saude_frontend/app/router/go_router.dart';
import 'package:minha_saude_frontend/config/google_auth_config.dart';
import 'package:minha_saude_frontend/config/mock_endpoint_config.dart';

final getIt = GetIt.I;

/// Awaits until all async singletons are ready
Future<void> setupLocator() async {
  // Core dependencies
  getIt.registerSingleton(
    MockEndpointConfig(
      googleSignInMode: GoogleSignInMode.mockSuccess,
      serverAuthMode: ServerAuthMode.mockExistingUser,
    ),
  );
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<DocumentScanner>(DocumentScanner());
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<GoogleAuthConfig>(GoogleAuthConfig());
  getIt.registerSingleton<AppTheme>(AppTheme());
  getIt.registerSingleton<GoRouter>(router);
  getIt.registerSingleton<TokenRepository>(
    TokenRepository(getIt<SecureStorage>()),
  );

  // ApiClient (depends on Dio and TokenRepository)
  getIt.registerSingleton<ApiClient>(
    ApiClient(getIt<Dio>(), getIt<TokenRepository>()),
  );

  // AuthRemoteService (depends on ApiClient)
  getIt.registerSingleton<AuthRemoteService>(
    AuthRemoteService(getIt<ApiClient>()),
  );

  // GoogleSignInService (async, no dependencies on auth)
  getIt.registerSingletonAsync<GoogleSignInService>(() async {
    return await GoogleSignInService.create(
      GoogleSignIn.instance,
      GoogleAuthConfig(),
    );
  });

  // AuthRepository (depends on remote service, Google service, and token repository)
  getIt.registerSingletonAsync<AuthRepository>(
    () async => AuthRepository(
      getIt<AuthRemoteService>(),
      getIt<GoogleSignInService>(),
      getIt<TokenRepository>(),
    ),
    dependsOn: [GoogleSignInService],
  );

  getIt.registerSingleton<DocumentRepository>(DocumentRepository());
  getIt.registerSingleton<ProfileRepository>(ProfileRepository());
  getIt.registerSingleton<DocumentUploadRepository>(
    DocumentUploadRepository(getIt<DocumentScanner>()),
  );

  // Await on async operations
  await getIt.allReady();
}
