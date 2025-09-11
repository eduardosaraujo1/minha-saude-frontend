import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_local_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_remote_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/google_sign_in_service.dart';
import 'package:minha_saude_frontend/app/data/shared/services/api_client.dart';
import 'package:minha_saude_frontend/app/data/shared/services/secure_storage.dart';
import 'package:minha_saude_frontend/app/domain/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/presentation/shared/themes/app_theme.dart';
import 'package:minha_saude_frontend/app/router/go_router.dart';
import 'package:minha_saude_frontend/config/google_auth_config.dart';

final getIt = GetIt.I;

/// Awaits until all async singletons are ready
Future<void> setupLocator() async {
  // Providers
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<GoogleAuthConfig>(GoogleAuthConfig());
  getIt.registerSingleton<AppTheme>(AppTheme());
  getIt.registerSingleton<GoRouter>(router);
  getIt.registerSingleton<AuthLocalService>(
    AuthLocalService(getIt<SecureStorage>()),
  );
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<AuthRemoteService>(
    AuthRemoteService(getIt<ApiClient>()),
  );
  getIt.registerSingletonAsync(() async {
    return GoogleSignInService.create(
      GoogleSignIn.instance,
      GoogleAuthConfig(),
    );
  });
  getIt.registerSingletonAsync<AuthRepository>(
    () async => AuthRepositoryImpl.create(
      getIt<AuthLocalService>(),
      getIt<AuthRemoteService>(),
      getIt<GoogleSignInService>(),
    ),
    dependsOn: [GoogleSignInService],
  );

  // Await on async operations
  await getIt.allReady();
}
