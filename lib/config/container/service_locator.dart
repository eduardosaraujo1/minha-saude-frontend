import 'package:minha_saude_frontend/config/container/service_locator_impl.dart';

abstract class ServiceLocator {
  static ServiceLocator get I => ServiceLocatorImpl();

  bool get isLocked;

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
}

class ServiceLocatorException implements Exception {
  final String message;

  ServiceLocatorException(this.message);

  @override
  String toString() => 'ServiceLocatorException: $message';
}
