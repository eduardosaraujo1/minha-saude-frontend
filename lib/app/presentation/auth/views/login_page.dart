import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/auth/widgets/button_sign_in.dart';
import 'package:minha_saude_frontend/app/presentation/auth/widgets/login_decorator.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/login_view_model.dart';
import 'package:watch_it/watch_it.dart';

class LoginPage extends WatchingWidget {
  final LoginViewModel viewModel;

  LoginPage({viewModel, super.key}) : viewModel = viewModel ?? LoginViewModel();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final result = watch(viewModel.loginCommand.results).value;

    // Handle UI updates after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (result.hasData) {
        if (result.data! == LoginStatus.authenticated) {
          context.go('/home');
        } else if (result.data! == LoginStatus.needsRegistration) {
          context.go('/tos');
        } else if (result.data! == LoginStatus.error) {
          final snackBar = SnackBar(
            content: Text(
              viewModel.errorMessage ?? 'Ocorreu um erro desconhecido',
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else if (result.hasError) {
        final snackBar = SnackBar(
          content: Text(
            result.error?.toString() ?? 'Ocorreu um erro desconhecido',
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoginDecoratorWidget(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Text("Iniciar Sessão", style: theme.textTheme.titleLarge),
                ButtonSignIn(
                  icon: SvgPicture.asset(
                    'assets/brand/google/logo.svg',
                    width: 24,
                  ),
                  label: "Entrar com Google",
                  onPressed: () {
                    viewModel.loginCommand.execute();
                  },
                  disabled: result.isExecuting,
                ),
                if (result.isExecuting)
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
