import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../view_models/login_view_model.dart';
import '../widgets/button_sign_in.dart';
import '../widgets/login_decorator.dart';

class LoginView extends StatefulWidget {
  final LoginViewModel viewModel;
  const LoginView(this.viewModel, {super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  LoginViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_onStateUpdate);
  }

  @override
  void dispose() {
    viewModel.removeListener(_onStateUpdate);
    viewModel.dispose();
    super.dispose();
  }

  void _onStateUpdate() {
    final state = viewModel.state;

    if (state is LoginErrorState) {
      _onError(state.message);
    } else if (state is LoginRedirectState) {
      _onRedirect(state.redirectTo);
    } else {
      // Rebuild widget
      setState(() {});
    }
  }

  void _onError(String errorMessage) {
    final snackBar = SnackBar(
      content: Text(errorMessage),
      backgroundColor: Theme.of(context).colorScheme.error,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onRedirect(String? redirectPath) {
    if (redirectPath != null && redirectPath.isNotEmpty) {
      context.goNamed(redirectPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = viewModel.state is LoginLoadingState;

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
                  onPressed: isLoading
                      ? null
                      : () => viewModel.loginWithGoogle(),
                ),
                SizedBox(height: 8),
                if (isLoading)
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
