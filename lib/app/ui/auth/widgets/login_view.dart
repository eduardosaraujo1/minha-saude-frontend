import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../../../../config/asset.dart';
import '../view_models/login_view_model.dart';
import 'button_sign_in.dart';
import 'login_decorator.dart';

class LoginView extends StatefulWidget {
  const LoginView(this.viewModel, {super.key});

  final LoginViewModel viewModel;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  LoginViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.loginWithGoogle.addListener(_onUpdate);
  }

  @override
  void dispose() {
    viewModel.loginWithGoogle.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    try {
      final loginCommand = viewModel.loginWithGoogle;
      final result = loginCommand.value;

      if (result == null) return;

      if (result.isSuccess()) {
        final redirectPath = result.getOrThrow();
        if (mounted) context.go(redirectPath);

        return;
      }

      if (result.isError()) {
        final error = result.tryGetError()!;
        _showErrorSnack(error.toString());
        return;
      }

      setState(() {});
    } catch (e) {
      Logger("LoginView").severe("Ocorreu um erro desconhecido: $e");
      _showErrorSnack("Ocorreu um erro desconhecido.");
    }
  }

  void _showErrorSnack(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      backgroundColor: Theme.of(context).colorScheme.error,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final loginWithGoogle = viewModel.loginWithGoogle;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoginDecorator(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: ListenableBuilder(
              listenable: Listenable.merge([
                loginWithGoogle.isExecuting, //
              ]),
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Iniciar Sessão",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ButtonSignIn(
                      icon: SvgPicture.asset(Asset.googleLogo, width: 24),
                      label: "Entrar com Google",
                      onPressed: loginWithGoogle.isExecuting.value
                          ? null
                          : () => loginWithGoogle.execute(),
                    ),
                    SizedBox(height: 8),
                    if (loginWithGoogle.isExecuting.value)
                      SizedBox(
                        width: double.infinity,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
