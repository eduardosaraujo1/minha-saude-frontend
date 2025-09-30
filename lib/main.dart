import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/ui/core/themes/app_theme.dart';
import 'package:minha_saude_frontend/config/container/service_locator.dart';

import 'main_development.dart' as development;

void main() async {
  development.main();
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
