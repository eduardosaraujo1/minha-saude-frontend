import 'package:dio/dio.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/repositories/google_auth_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/repositories/token_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/services/api_client.dart';
import 'package:minha_saude_frontend/app/data/services/secure_storage.dart';
import 'package:minha_saude_frontend/app/domain/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/domain/repositories/google_auth_repository.dart';
import 'package:minha_saude_frontend/app/domain/repositories/token_repository.dart';
import 'package:minha_saude_frontend/core/config/google_auth_config.dart';
import 'package:minha_saude_frontend/core/config/mock_endpoint_config.dart';
import 'package:minha_saude_frontend/routing/go_router.dart';

import 'container.dart';

class AppServiceProvider extends ServiceProvider {
  @override
  void register() {
    container.singleton(
      MockEndpointConfig(
        googleSignInMode: GoogleSignInMode.mockSuccess,
        serverAuthMode: ServerAuthMode.mockExistingUser,
        documentCreateMode: DocumentCreateMode.scan,
      ),
    );

    // Core services
    container.singleton(RouterFactory.create());
    container.singleton(Dio());
    container.singleton(ApiClient(container<Dio>()));
    container.singleton(SecureStorage());

    // Repositories
    container.singleton<GoogleAuthRepository>(
      GoogleAuthRepositoryImpl(container<GoogleAuthConfig>()),
    );
    container.singleton<TokenRepository>(
      TokenRepositoryImpl(container<SecureStorage>(), container<ApiClient>()),
    );
    container.singleton<AuthRepository>(
      AuthRepositoryImpl(container<ApiClient>()),
    );
  }

  @override
  Future<void> bind() async {
    await container<TokenRepository>().reload();
  }
}

abstract class ServiceProvider {
  final container = ServiceLocator.I;

  /// Sets up the service provider by registering services,
  /// waiting for async services to be ready, and freezing the container.
  /// This method should be called once during app initialization.
  Future<void> setup() async {
    if (container.isFrozen) {
      throw Exception(
        'Container is already freezed. Setup can only be called once.',
      );
    }

    // Register all services
    register();

    // Wait for all async singletons to be ready
    await container.allReady();

    // Run code after all services are ready
    // For example, you might want to preload some data
    await bind();

    // Close the container for further registrations
    container.freeze();
  }

  /// Registers services into the service locator.
  void register();

  /// Runs code after all services are registered and ready.
  Future<void> bind();
}
