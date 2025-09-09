import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/shared/sources/api_client.dart';
import 'package:minha_saude_frontend/app/data/shared/sources/secure_storage.dart';
import 'package:minha_saude_frontend/config/google_auth_config.dart';
import 'package:minha_saude_frontend/routes/go_router.dart';

final getIt = GetIt.instance;

void setup() {
  // Secure storage
  getIt.registerSingleton<SecureStorage>(SecureStorage());

  // HTTP API client
  getIt.registerSingleton<ApiClient>(ApiClient());

  // Router
  getIt.registerSingleton<GoRouter>(router);

  // Google Config
  getIt.registerSingleton<GoogleAuthConfig>(GoogleAuthConfig());
}
