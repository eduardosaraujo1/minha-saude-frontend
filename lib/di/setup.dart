import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/routing/go_router.dart';

import 'container.dart';

class AppServiceProvider extends ServiceProvider {
  @override
  void register() {
    container.singleton<Dio>(Dio());
    container.singleton<RouterConfig<Object>>(RouterFactory.create());
  }

  @override
  Future<void> bind() async {
    // Stuff to do after registering all services
    // await getIt<TokenRepository>().reload();
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
