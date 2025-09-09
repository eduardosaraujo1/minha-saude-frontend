import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/presentation/shared/themes/app_theme.dart';
import 'package:minha_saude_frontend/old/state/get_it.dart';

/// The main entry point of the application.
///
/// This function initializes the service locator and runs the app.
/// If any required environment variables are missing during setup,
/// it will display an error screen instead of crashing.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    configureDependencies();
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
      theme: AppTheme.light(),
      routerConfig: GetIt.I<GoRouter>(),
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
