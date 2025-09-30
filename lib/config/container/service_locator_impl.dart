import 'package:get_it/get_it.dart';
import 'package:minha_saude_frontend/config/container/service_locator.dart';

class ServiceLocatorImpl implements ServiceLocator {
  final _getIt = GetIt.I;

  bool _isLocked = false;

  @override
  bool get isLocked => _isLocked;

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
}
