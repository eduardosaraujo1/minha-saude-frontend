import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minha_saude_frontend/ui/auth/widgets/login_decorator.dart';
import 'package:minha_saude_frontend/ui/auth/widgets/sign_in_button.dart';
import 'package:minha_saude_frontend/ui/auth/view_model/login_view_model.dart';

class LoginScreen extends StatelessWidget {
  final LoginViewModel _viewModel;

  const LoginScreen({required LoginViewModel viewModel, super.key})
    : _viewModel = viewModel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
                Text("Iniciar Sessão", style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),
                SignInButton(
                  icon: SvgPicture.asset(
                    'assets/brand/google/logo.svg',
                    width: 24,
                  ),
                  label: Text(
                    "Entrar com Google",
                    style: theme.textTheme.bodyLarge,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(height: 8),
                SignInButton(
                  icon: Icon(Icons.mail_outline, size: 24),
                  label: Text(
                    "Entrar com E-mail",
                    style: theme.textTheme.bodyLarge,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
