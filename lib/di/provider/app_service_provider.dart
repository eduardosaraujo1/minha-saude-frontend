import 'package:dio/dio.dart';
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

import 'service_provider.dart';

class AppServiceProvider extends ServiceProvider {
  @override
  Future<void> register() async {
    // Core dependencies
    locator.register(
      MockEndpointConfig(
        googleSignInMode: GoogleSignInMode.mockSuccess,
        serverAuthMode: ServerAuthMode.mockExistingUser,
      ),
    );
    locator.register<Dio>(Dio());
    locator.register<DocumentScanner>(DocumentScanner());
    locator.register<SecureStorage>(SecureStorage());
    locator.register<GoogleAuthConfig>(GoogleAuthConfig());
    locator.register<AppTheme>(AppTheme());
    locator.register<GoRouter>(router);
    locator.register<TokenRepository>(
      TokenRepository(locator<SecureStorage>()),
    );

    // ApiClient (depends on Dio and TokenRepository)
    locator.register<ApiClient>(
      ApiClient(locator<Dio>(), locator<TokenRepository>()),
    );

    // AuthRemoteService (depends on ApiClient)
    locator.register<AuthRemoteService>(
      AuthRemoteService(locator<ApiClient>()),
    );

    // GoogleSignInService (async)
    locator.register<GoogleSignInService>(
      await GoogleSignInService.create(
        GoogleSignIn.instance,
        locator<GoogleAuthConfig>(),
      ),
    );

    // AuthRepository (depends on remote service, Google service, and token repository)
    locator.registerAsync<AuthRepository>(
      () async => AuthRepository(
        locator<AuthRemoteService>(),
        locator<GoogleSignInService>(),
        locator<TokenRepository>(),
      ),
    );

    locator.register<DocumentRepository>(DocumentRepository());
    locator.register<ProfileRepository>(ProfileRepository());
    locator.register<DocumentUploadRepository>(
      DocumentUploadRepository(locator<DocumentScanner>()),
    );
  }

  @override
  Future<void> bind() async {
    // Bind app-specific services here
  }
}
