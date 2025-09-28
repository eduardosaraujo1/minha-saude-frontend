import 'package:minha_saude_frontend/config/di/service_locator.dart';

export 'app_service_provider.dart';
export 'local_service_provider.dart';
export 'remote_service_provider.dart';

abstract class ServiceProvider {
  ServiceLocator get locator => ServiceLocator.I;

  /// Register services in the service locator.
  Future<void> register();

  /// Configure or bind services after registration.
  Future<void> bind();
}
