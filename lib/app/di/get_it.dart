import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_token_repository.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_cache_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_storage_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_remote_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/google_sign_in_service.dart';
import 'package:minha_saude_frontend/app/data/shared/services/api_client.dart';
import 'package:minha_saude_frontend/app/data/shared/services/secure_storage.dart';
import 'package:minha_saude_frontend/app/presentation/shared/themes/app_theme.dart';
import 'package:minha_saude_frontend/app/router/go_router.dart';
import 'package:minha_saude_frontend/config/google_auth_config.dart';

final getIt = GetIt.I;

/// Awaits until all async singletons are ready
Future<void> setupLocator() async {
  // Core dependencies
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<GoogleAuthConfig>(GoogleAuthConfig());
  getIt.registerSingleton<AppTheme>(AppTheme());
  getIt.registerSingleton<GoRouter>(router);

  // Auth token management (no external dependencies)
  getIt.registerSingleton<AuthCacheService>(AuthCacheService());
  getIt.registerSingleton<AuthStorageService>(
    AuthStorageService(getIt<SecureStorage>()),
  );

  // AuthTokenRepository (depends on cache and storage services)
  getIt.registerSingletonAsync<AuthTokenRepository>(
    () async => AuthTokenRepository.create(
      getIt<AuthCacheService>(),
      getIt<AuthStorageService>(),
    ),
  );

  // ApiClient (depends on Dio and AuthTokenRepository - no circular dependency!)
  getIt.registerSingletonAsync<ApiClient>(
    () async => ApiClient(getIt<Dio>(), getIt<AuthTokenRepository>()),
    dependsOn: [AuthTokenRepository],
  );

  // AuthRemoteService (depends on ApiClient)
  getIt.registerSingletonAsync<AuthRemoteService>(
    () async => AuthRemoteService(getIt<ApiClient>()),
    dependsOn: [ApiClient],
  );

  // GoogleSignInService (async, no dependencies on auth)
  getIt.registerSingletonAsync<GoogleSignInService>(() async {
    return GoogleSignInService.create(
      GoogleSignIn.instance,
      GoogleAuthConfig(),
    );
  });

  // AuthRepository (depends on remote service, Google service, token repository, and cache service)
  getIt.registerSingletonAsync<AuthRepository>(
    () async => AuthRepository.create(
      getIt<AuthRemoteService>(),
      getIt<GoogleSignInService>(),
      getIt<AuthTokenRepository>(),
      getIt<AuthCacheService>(),
    ),
    dependsOn: [AuthRemoteService, GoogleSignInService, AuthTokenRepository],
  );

  // Await on async operations
  await getIt.allReady();
}
