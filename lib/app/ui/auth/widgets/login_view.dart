import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';

import '../../../../config/asset.dart';
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
        final loginResult = result.tryGetSuccess()!;
        final redirectPath = switch (loginResult) {
          SuccessfulLoginResult() => Routes.home,
          NeedsRegistrationLoginResult() => Routes.register,
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoginDecorator(),
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([loginWithGoogle.isExecuting]),
              builder: (context, child) {
                final isLoading = loginWithGoogle.isExecuting.value;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Iniciar Sessão",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ButtonSignIn(
                        key: const ValueKey("btnLoginGoogle"),
                        icon: SvgPicture.asset(Asset.googleLogo, width: 24),
                        label: "Entrar com Google",
                        onPressed: isLoading
                            ? null
                            : () => loginWithGoogle.execute(),
                      ),
                      SizedBox(height: 8),
                      ButtonSignIn(
                        key: const ValueKey("btnLoginEmail"),
                        icon: Icon(
                          Icons.email,
                          color: colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        label: "Entrar com Email",
                        onPressed: isLoading
                            ? null
                            : () => context.go(Routes.emailAuth),
                      ),
                      SizedBox(height: 8),
                      if (isLoading)
                        SizedBox(
                          width: double.infinity,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
