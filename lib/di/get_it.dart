import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_remote_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/google_sign_in_service.dart';
import 'package:minha_saude_frontend/app/data/document/repositories/document_repository.dart';
import 'package:minha_saude_frontend/app/data/document/repositories/document_upload_repository.dart';
import 'package:minha_saude_frontend/app/data/shared/repositories/token_repository.dart';
import 'package:minha_saude_frontend/app/data/shared/services/api_client.dart';
import 'package:minha_saude_frontend/app/data/shared/services/secure_storage.dart';
import 'package:minha_saude_frontend/app/presentation/shared/themes/app_theme.dart';
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
  getIt.registerSingleton<DocumentUploadRepository>(DocumentUploadRepository());

  // Await on async operations
  await getIt.allReady();
}
