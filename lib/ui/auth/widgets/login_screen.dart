import 'package:flutter/material.dart';
import '../view_model/login_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({required LoginViewModel viewModel, super.key})
    : _viewModel = viewModel;

  final LoginViewModel _viewModel;

  // TODO: Add sign in with google button, putting logic in the _viewModel and using the Command pattern along side the Result class
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Login Form')),
    );
  }
}
