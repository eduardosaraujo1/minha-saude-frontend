import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/shared/sources/secure_storage.dart';
import 'package:minha_saude_frontend/app/presentation/shared/themes/app_theme.dart';
import 'package:minha_saude_frontend/config/google_auth_config.dart';
import 'package:minha_saude_frontend/container/get_it.dart';
import 'package:minha_saude_frontend/routes/go_router.dart';

void setup() {
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<GoogleAuthConfig>(GoogleAuthConfig());
  getIt.registerSingleton<AppTheme>(AppTheme());
  getIt.registerSingleton<GoRouter>(router);
}
