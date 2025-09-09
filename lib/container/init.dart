import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:minha_saude_frontend/routes/go_router.dart';
import 'package:minha_saude_frontend/container/providers/auth_provider.dart';
import 'package:minha_saude_frontend/data/profile/sources/user_profile_remote_source.dart';
import 'package:minha_saude_frontend/data/profile/repositories/user_profile_repository_impl.dart';
import 'package:minha_saude_frontend/domain/profile/repositories/user_profile_repository.dart';

// The single instance of GetIt
final getIt = GetIt.instance;

/// Initialize all providers and dependencies
void initProviders() {
  // Register core services
  _registerCoreServices();

  // Register feature providers
  _registerAuthProviders();
  _registerProfileProviders();

  // Add other feature initializations here
}

/// Register core services used throughout the app
void _registerCoreServices() {
  // Secure storage
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  // HTTP client
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Router
  getIt.registerLazySingleton<GoRouter>(() => makeRouter());

  // API base URL
  getIt.registerLazySingleton<String>(
    () => 'https://api.minhasaude.com',
    instanceName: 'apiBaseUrl',
  );
}

/// Register auth-related providers
void _registerAuthProviders() {
  // Auth provider
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(getIt<FlutterSecureStorage>()),
  );

  // Add other auth-related providers
}

/// Register profile-related providers
void _registerProfileProviders() {
  // Remote source
  getIt.registerLazySingleton<UserProfileRemoteSource>(
    () => UserProfileRemoteSource(
      getIt<http.Client>(),
      getIt<String>(instanceName: 'apiBaseUrl'),
    ),
  );

  // Repository
  getIt.registerLazySingleton<IUserProfileRepository>(
    () => UserProfileRepositoryImpl(
      getIt<UserProfileRemoteSource>(),
      cacheValidity: const Duration(minutes: 15),
    ),
  );
}
