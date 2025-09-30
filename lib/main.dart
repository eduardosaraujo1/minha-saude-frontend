import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/ui/core/themes/app_theme.dart';
import 'package:minha_saude_frontend/config/container/service_locator.dart';
import 'package:minha_saude_frontend/config/providers/service_provider.dart';

import 'main_development.dart' as development;

void main() async {
  development.main();
}

class Application {
  Application._internal();

  List<ServiceProvider> _providers = [];

  static final locator = ServiceLocator.I;
  final _log = Logger("Application");

  Future<void> _setupProviders() async {
    final providers = _providers;

    // Ensure the locator is not locked
    if (locator.isLocked) {
      throw Exception(
        'ServiceLocator is already frozen. Cannot setup providers.',
      );
    }

    // First, call .register() on each provider
    for (final provider in providers) {
      await provider.register();
    }
    // Then await until this container is allReady()
    await locator.allReady();

    // Then, call .bind() on each provider
    for (final provider in providers) {
      await provider.bind();
    }

    // Finally, freeze the ServiceLocator to prevent further modifications
    locator.freeze();
  }

  static Application configure({Level logLevel = Level.ALL}) {
    Logger.root.level = logLevel;

    return Application._internal();
  }

  Application withProviders(List<ServiceProvider> providers) {
    _providers = providers;

    return this;
  }

  Future<void> run() async {
    try {
      await _setupProviders();

      runApp(const MyApp());
    } catch (e) {
      _log.severe('Failed to run app: $e');
      runApp(InitErrorWidget(e));
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = ServiceLocator.I<AppTheme>();

    return MaterialApp.router(
      title: 'Minha Saúde',
      theme: appTheme.selectedTheme,
      routerConfig: ServiceLocator.I<GoRouter>(),
    );
  }
}

/// A widget that displays an initialization error message.
///
/// This widget is shown when the app fails to initialize due to missing
/// configuration or other setup errors.
class InitErrorWidget extends StatelessWidget {
  final Object error;

  const InitErrorWidget(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Initialization Error:\n${error.toString()}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
