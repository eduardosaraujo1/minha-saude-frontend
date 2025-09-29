import 'package:flutter/material.dart';

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
