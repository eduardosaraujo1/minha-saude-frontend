import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/document_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/document_upload_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile_repository.dart';
import 'package:minha_saude_frontend/app/data/services/api/api_client.dart';
import 'package:minha_saude_frontend/app/data/services/document_scanner.dart';
import 'package:minha_saude_frontend/app/data/services/google/google_service.dart';
import 'package:minha_saude_frontend/app/data/services/secure_storage.dart';
import 'package:minha_saude_frontend/app/ui/core/themes/app_theme.dart';
import 'package:minha_saude_frontend/config/project_settings.dart';
import 'package:minha_saude_frontend/config/router/go_router.dart';

import 'service_provider.dart';

class DevelopmentServiceProvider extends ServiceProvider {
  @override
  Future<void> register() async {
    // Configs
    locator.register<ProjectSettings>(
      ProjectSettings(
        apiBaseUrl: 'https://localhost:8000',
        mockApiClient: true,
        mockGoogle: !(Platform.isAndroid || Platform.isMacOS),
        mockScanner: !Platform.isAndroid,
        mockSecureStorage: true,
      ),
    );
    locator.register<GoogleAuthConfig>(
      GoogleAuthConfig.fromEnv(
        scopes: <String>[
          'https://www.googleapis.com/auth/userinfo.email',
          'openid',
        ],
      ),
    );

    locator.register<SecureStorage>(SecureStorage());
    locator.register<DocumentScanner>(DocumentScanner());

    // Services
    locator.register<ApiClient>(
      // ApiClientImpl(Dio(), locator<ProjectSettings>().apiBaseUrl),
      FakeApiClient(),
    );
    locator.register<GoogleService>(
      locator<ProjectSettings>().mockGoogle
          ? GoogleServiceFake()
          : GoogleServiceImpl(
              locator<GoogleAuthConfig>(),
              GoogleSignIn.instance,
            ),
    );

    // Repositories
    locator.register<AuthRepository>(
      AuthRepositoryImpl(
        locator<SecureStorage>(),
        locator<GoogleService>(),
        locator<ApiClient>(),
      ),
    );
    locator.register<DocumentRepository>(DocumentRepository());
    locator.register<ProfileRepository>(ProfileRepository());
    locator.register<DocumentUploadRepository>(
      DocumentUploadRepository(locator<DocumentScanner>()),
    );

    // App UI dependencies
    locator.register<AppTheme>(AppTheme());
    locator.register<GoRouter>(
      AppRouter(
        locator<AuthRepository>(),
        locator<DocumentRepository>(),
        locator<DocumentUploadRepository>(),
        locator<ProfileRepository>(),
      ).router(),
    );
  }

  @override
  Future<void> bind() async {
    // Bind app-specific services here
  }
}
