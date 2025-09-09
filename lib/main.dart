import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/shared/themes/app_theme.dart';
import 'package:minha_saude_frontend/container/providers/providers.dart'
    as container;
import 'package:watch_it/watch_it.dart';

/// The main entry point of the application.
///
/// This function initializes the service locator and runs the app.
/// If any required environment variables are missing during setup,
/// it will display an error screen instead of crashing.
void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize all providers and dependencies
    container.initProviders();

    // Wait until getIt sets up all the async services
    await container.allReady();

    // Run the app
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Failed to run app: $e');

    runApp(InitErrorWidget(e));
  }
}

class MyApp extends WatchingWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = watchIt<AppTheme>();

    return MaterialApp.router(
      title: 'Minha Saúde 2025',
      theme: appTheme.selectedTheme,
      routerConfig: GetIt.I<GoRouter>(),
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
