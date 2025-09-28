import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/services/google/google_service.dart';
import 'package:minha_saude_frontend/app/data/services/document_scanner.dart';
import 'package:minha_saude_frontend/app/data/services/secure_storage.dart';
import 'package:minha_saude_frontend/app/ui/core/themes/app_theme.dart';
import 'package:minha_saude_frontend/config/router/go_router.dart';

import 'service_provider.dart';

class AppServiceProvider extends ServiceProvider {
  @override
  Future<void> register() async {
    // Configs
    locator.register<GoogleAuthConfig>(
      GoogleAuthConfig.fromEnv(
        scopes: <String>[
          'https://www.googleapis.com/auth/userinfo.email',
          'openid',
        ],
      ),
    );

    // Core Services
    locator.register<SecureStorage>(SecureStorage());
    locator.register<DocumentScanner>(DocumentScanner());

    // App UI dependencies
    locator.register<AppTheme>(AppTheme());
    locator.register<GoRouter>(router);
  }

  @override
  Future<void> bind() async {
    // Bind app-specific services here
  }
}
