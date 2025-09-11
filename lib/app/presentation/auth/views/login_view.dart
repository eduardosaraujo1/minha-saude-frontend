import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/auth/widgets/button_sign_in.dart';
import 'package:minha_saude_frontend/app/presentation/auth/widgets/login_decorator.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/login_view_model.dart';

class LoginView extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginView(this.viewModel, {super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    final status = widget.viewModel.status;
    if (status == LoginStatus.authenticated) {
      context.go('/home');
    } else if (status == LoginStatus.needsRegistration) {
      context.go('/tos');
    } else if (status == LoginStatus.error) {
      final errorMessage =
          widget.viewModel.errorMessage ?? 'Ocorreu um erro desconhecido';
      final snackBar = SnackBar(content: Text(errorMessage));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
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
                  onPressed: vm.isLoading
                      ? null
                      : () {
                          vm.loginWithGoogle();
                        },
                  disabled: vm.isLoading,
                ),
                if (vm.isLoading)
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
