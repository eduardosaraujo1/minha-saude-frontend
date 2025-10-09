import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import 'app/routing/router.dart';
import 'app/ui/core/theme_provider.dart';
import 'config/dependencies_dev.dart' as dev;
import 'config/dependencies_prod.dart' as prod;
import 'config/environment.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    Logger.root.level = Level.ALL;

    Command.globalExceptionHandler = (error, stackTrace) {
      throw error;
    };

    if (Environment.appEnv.isDev) {
      await dev.setup(
        mockApiClient: true,
        // mockGoogle: !(Platform.isAndroid || Platform.isIOS),
        mockGoogle: true,
        mockScanner: true,
        mockSecureStorage: false,
      );
    } else {
      await prod.setup();
    }

    runApp(const MyApp());
  } catch (e, stackTrace) {
    runApp(ErrorApp(e, stackTrace: stackTrace));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themeProvider = GetIt.I<ThemeProvider>();

  @override
  void initState() {
    super.initState();

    themeProvider.mode.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeProvider.mode.removeListener(_onThemeChanged);

    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData darkTheme = themeProvider.darkTheme;
    final ThemeData lightTheme = themeProvider.lightTheme;

    return MaterialApp.router(
      title: 'Minha Saúde',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.mode.value,
      routerConfig: router(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorApp(this.error, {this.stackTrace, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Application Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'An error occurred during app initialization',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error Details:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  error.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
              if (stackTrace != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Stack Trace:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        stackTrace.toString(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
