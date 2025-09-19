import 'package:get_it/get_it.dart';

class ServiceLocator {
  // Singleton pattern
  static final _instance = ServiceLocator._internal();
  static final _getIt = GetIt.instance;

  static ServiceLocator get I => _instance;
  static ServiceLocator get instance => _instance;

  ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  // Properties
  bool _freezed = false;
  bool get isFrozen => _freezed;

  // Methods
  void freeze() {
    _freezed = true;
  }

  Future<void> allReady() {
    return _getIt.allReady();
  }

  // Get methods
  T get<T extends Object>() {
    return _getIt.get<T>();
  }

  T call<T extends Object>() {
    return get<T>();
  }

  // Register methods
  T singleton<T extends Object>(T instance) {
    _checkFreezed();
    return _getIt.registerSingleton<T>(instance);
  }

  void singletonAsync<T extends Object>(Future<T> Function() factoryFunc) {
    _checkFreezed();
    _getIt.registerSingletonAsync<T>(factoryFunc);
  }

  // Utility methods
  void _checkFreezed() {
    if (_freezed) {
      throw Exception('Container is freezed. No more registrations allowed.');
    }
  }
}
