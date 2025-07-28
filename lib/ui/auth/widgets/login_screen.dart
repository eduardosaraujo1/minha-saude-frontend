import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/utils/result.dart';
import 'package:flutter/services.dart';
import '../view_model/login_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({required LoginViewModel viewModel, super.key})
    : _viewModel = viewModel;

  final LoginViewModel _viewModel;

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          children: [
            Text('Login Form'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await _viewModel.getAuthCode();
                if (!context.mounted) return;

                late String message;
                if (result is Error) {
                  message = 'Error signing in: ${(result as Error).error}';
                } else {
                  message = (result as Ok<String?>).value ?? 'No auth code';
                }

                showSnackBar(context, message);
                copyToClipboard(message);
              },
              child: const Text('Show token'),
            ),
          ],
        ),
      ),
    );
  }
}
