import 'dependencies/dependencies.dart';

var _initialized = false;

Future<void> registerDependencies(List<Dependencies> dependencies) async {
  if (_initialized) {
    throw Exception('Bootstrap.init() should only be called once.');
  }

  for (final dep in dependencies) {
    await dep.register();
  }

  for (final dep in dependencies) {
    await dep.bind();
  }

  // Block further calls to init()
  _initialized = true;
}
