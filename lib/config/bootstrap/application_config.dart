import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/config/container/service_locator.dart';
import 'package:minha_saude_frontend/config/providers/service_provider.dart';

class ApplicationConfig {
  ApplicationConfig({
    required ServiceLocator serviceLocator,
    required List<ServiceProvider> providers,
  }) : _serviceLocator = serviceLocator,
       _providers = providers;

  final ServiceLocator _serviceLocator;
  final List<ServiceProvider> _providers;

  final _log = Logger("Application");

  Future<void> setup() async {
    await _setupProviders();
  }

  Future<void> _setupProviders() async {
    final providers = _providers;

    // Ensure the locator is not locked
    if (_serviceLocator.isLocked) {
      throw Exception(
        'ServiceLocator is already frozen. Cannot setup providers.',
      );
    }

    // First, call .register() on each provider
    for (final provider in providers) {
      _log.fine("Registering services from ${provider.runtimeType}");
      await provider.register();
    }
    // Then await until this container is allReady()
    await _serviceLocator.allReady();

    // Then, call .bind() on each provider
    for (final provider in providers) {
      _log.fine("Binding services from ${provider.runtimeType}");
      await provider.bind();
    }

    // Finally, freeze the ServiceLocator to prevent further modifications
    _serviceLocator.freeze();
  }
}
