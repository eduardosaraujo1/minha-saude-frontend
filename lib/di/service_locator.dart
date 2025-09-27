import 'package:get_it/get_it.dart';
import 'package:minha_saude_frontend/di/provider/service_provider.dart';

abstract class ServiceLocator {
  static ServiceLocator get I => ServiceLocatorImpl();

  /// Gets a registered service of type [T].
  T call<T extends Object>();

  /// Gets a registered service of type [T].
  T get<T extends Object>();

  /// Registers a singleton service of type [T].
  void register<T extends Object>(T instance);

  /// Registers a singleton service of type [T].
  void registerAsync<T extends Object>(Future<T> Function() instance);

  /// Awaits until all async singletons are ready
  Future<void> allReady();

  /// Freezes the service locator to prevent further modifications.
  void freeze();

  /// Unfreezes the service locator to allow modifications.
  void unfreeze();

  /// Sets up the service locator with the provided list of [ServiceProvider]s.
  Future<void> setupProviders(List<ServiceProvider> providers);
}

class ServiceLocatorImpl implements ServiceLocator {
  final _getIt = GetIt.I;

  bool _isLocked = false;

  void _assertNotLocked() {
    if (_isLocked) {
      throw ServiceLocatorException(
        'ServiceLocator is frozen. Cannot modify services.',
      );
    }
  }

  @override
  T call<T extends Object>() {
    return _getIt.get<T>();
  }

  @override
  T get<T extends Object>() {
    return _getIt.get<T>();
  }

  @override
  void register<T extends Object>(T instance) {
    _assertNotLocked();

    _getIt.registerSingleton<T>(instance);
  }

  @override
  void registerAsync<T extends Object>(Future<T> Function() instance) {
    _assertNotLocked();

    _getIt.registerSingletonAsync<T>(instance);
  }

  @override
  Future<void> allReady() {
    return _getIt.allReady();
  }

  @override
  void freeze() {
    _isLocked = true;
  }

  @override
  void unfreeze() {
    _isLocked = false;
  }

  @override
  Future<void> setupProviders(List<ServiceProvider> providers) async {
    // Ensure the locator is not locked
    _assertNotLocked();

    // First, call .register() on each provider
    for (final provider in providers) {
      await provider.register();
    }
    // Then await until this container is allReady()
    await allReady();

    // Then, call .bind() on each provider
    for (final provider in providers) {
      await provider.bind();
    }

    // Finally, freeze the ServiceLocator to prevent further modifications
    freeze();
  }
}

class ServiceLocatorException implements Exception {
  final String message;

  ServiceLocatorException(this.message);

  @override
  String toString() => 'ServiceLocatorException: $message';
}
