import 'package:logging/logging.dart';

import '../../config/dependencies/dependencies.dart';

class Application {
  static final _instance = Application._();

  Application._();

  factory Application() => _instance;

  bool _initialized = false;
  List<Dependencies> _dependencies = [];
  Level _logLevel = Level.INFO;

  Application withLogging(Level level) {
    _logLevel = level;
    return _instance;
  }

  Application withDependencies(List<Dependencies> dependencies) {
    _dependencies = dependencies;
    return _instance;
  }

  Future<void> init() async {
    _assertNotInitialized();

    // Setup logger level
    Logger.root.level = _logLevel;

    // Register and bind dependencies
    await _registerDependencies();

    // Mark app as initialized to prevent further modifications
    _initialized = true;
  }

  Future<void> _registerDependencies() async {
    _assertNotInitialized();

    for (final dep in _dependencies) {
      await dep.register();
    }

    for (final dep in _dependencies) {
      await dep.bind();
    }
  }

  void _assertNotInitialized() {
    if (_initialized) {
      throw Exception('Application is already initialized.');
    }
  }
}
