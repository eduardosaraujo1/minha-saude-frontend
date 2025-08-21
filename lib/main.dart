import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/di/injection.dart';
import 'package:minha_saude_frontend/ui/core/themes/theme.dart';
import 'package:minha_saude_frontend/routing/router.dart';

/// The main entry point of the application.
///
/// This function initializes the service locator and runs the app.
/// If any required environment variables are missing during setup,
/// it will display an error screen instead of crashing.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await configureDependencies();
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Failed to initialize app: $e');
    runApp(InitErrorWidget(message: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Minha Saúde 2025',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

/// A widget that displays an initialization error message.
///
/// This widget is shown when the app fails to initialize due to missing
/// configuration or other setup errors.
class InitErrorWidget extends StatelessWidget {
  final String message;

  const InitErrorWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Initialization Error:\n$message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
