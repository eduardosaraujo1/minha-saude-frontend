import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minha_saude_frontend/app/presentation/auth/widgets/button_sign_in.dart';
import 'package:minha_saude_frontend/app/presentation/auth/widgets/login_decorator.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/login_view_model.dart';
import 'package:watch_it/watch_it.dart';

class LoginView extends WatchingWidget {
  final LoginViewModel viewModel;

  const LoginView(this.viewModel, {super.key});

  void _onErrorChanged(BuildContext context, String? errorMessage) {
    final errorMessage = viewModel.errorMessage.value;

    if (errorMessage != null) {
      final snackBar = SnackBar(content: Text(errorMessage));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      viewModel.clearErrorMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final isLoading = watch(vm.isLoading);

    registerChangeNotifierHandler(
      target: vm.errorMessage,
      handler: (context, newValue, cancel) {
        _onErrorChanged(context, newValue.value);
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
                      : () {
                          vm.loginWithGoogle();
                        },
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
