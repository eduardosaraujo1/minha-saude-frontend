import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/auth/widgets/button_sign_in.dart';
import 'package:minha_saude_frontend/app/presentation/auth/widgets/login_decorator.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/login_view_model.dart';
import 'package:watch_it/watch_it.dart';

class LoginView extends WatchingWidget {
  final LoginViewModel viewModel;
  const LoginView(this.viewModel, {super.key});

  void _onError(BuildContext context, String? errorMessage) {
    if (errorMessage != null) {
      final snackBar = SnackBar(content: Text(errorMessage));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      viewModel.clearErrorMessages();
    }
  }

  void _onRedirect(BuildContext context, String? redirectPath) {
    if (redirectPath != null) {
      viewModel.redirectTo.value = null; // Clear redirect
      context.go(redirectPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final isLoading = watch(vm.isLoading);

    // Watch for error messages and handle them
    registerHandler<ValueNotifier<String?>, String?>(
      target: vm.errorMessage,
      handler: (context, newValue, cancel) {
        _onError(context, newValue);
      },
    );

    // Watch for redirects and handle them
    registerHandler<ValueNotifier<String?>, String?>(
      target: vm.redirectTo,
      handler: (context, String? newValue, cancel) {
        _onRedirect(context, newValue);
      },
    );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoginDecoratorWidget(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Iniciar Sessão",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ButtonSignIn(
                  icon: SvgPicture.asset(
                    'assets/brand/google/logo.svg',
                    width: 24,
                  ),
                  label: "Entrar com Google",
                  disabled: isLoading.value,
                  onPressed: isLoading.value
                      ? null
                      : () => vm.loginWithGoogle(),
                ),
                SizedBox(height: 8),
                if (isLoading.value)
                  SizedBox(
                    width: double.infinity,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
