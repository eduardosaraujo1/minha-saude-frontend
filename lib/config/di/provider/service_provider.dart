import '../service_locator.dart';

export 'development_service_provider.dart';
export 'production_service_provider.dart';

abstract class ServiceProvider {
  ServiceLocator get locator => ServiceLocator.I;

  /// Register services in the service locator.
  Future<void> register();

  /// Configure or bind services after registration.
  Future<void> bind();
}
