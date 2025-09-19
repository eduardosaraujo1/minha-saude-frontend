import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/di/container.dart';

import 'di/setup.dart';

void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize all services and dependencies
    await AppServiceProvider().setup();

    // Run the app
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Failed to run app: $e');

    runApp(InitErrorWidget(e));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final container = ServiceLocator.I;

    return MaterialApp.router(
      title: 'Minha Saúde 2025',
      // theme: appTheme.selectedTheme,
      routerConfig: container<RouterConfig<Object>>(),
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
