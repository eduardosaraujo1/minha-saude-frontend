import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../../../../config/asset.dart';
import '../../../domain/actions/auth/login_with_google.dart';
import '../../../routing/routes.dart';
import '../view_models/login_view_model.dart';
import 'button_sign_in.dart';
import 'login_decorator.dart';

class LoginView extends StatefulWidget {
  const LoginView(this.viewModelFactory, {super.key});

  final LoginViewModel Function() viewModelFactory;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModelFactory();
    viewModel.loginWithGoogle.addListener(_onUpdate);
  }

  @override
  void dispose() {
    viewModel.loginWithGoogle.removeListener(_onUpdate);
    viewModel.dispose();
    super.dispose();
  }

  void _onUpdate() {
    try {
      if (!mounted) return;
      final loginCommand = viewModel.loginWithGoogle;
      final result = loginCommand.value;

      if (result == null) return;

      if (result.isSuccess()) {
        final redirectResponse = result.tryGetSuccess()!;
        final redirectPath = switch (redirectResponse) {
          RedirectResponse.toHome => Routes.home,
          RedirectResponse.toRegister => Routes.tos,
        };
        context.go(redirectPath);

        return;
      }

      if (result.isError()) {
        final error = result.tryGetError()!;
        _showErrorSnack(error.toString());
        return;
      }

      // setState(() {});
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoginDecorator(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: ValueListenableBuilder(
              valueListenable: loginWithGoogle.isExecuting,
              builder: (context, googleLoginLoading, child) {
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
                      onPressed: googleLoginLoading
                          ? null
                          : () => loginWithGoogle.execute(),
                    ),
                    SizedBox(height: 8),
                    if (googleLoginLoading)
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
