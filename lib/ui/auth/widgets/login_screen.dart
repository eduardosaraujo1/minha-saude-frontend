import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minha_saude_frontend/ui/auth/widgets/login_decorator_widget.dart';
import 'package:minha_saude_frontend/ui/auth/widgets/sign_in_button.dart';
import 'package:minha_saude_frontend/utils/result.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Iniciar Sessão", style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),
                SignInButton(
                  icon: SvgPicture.asset('assets/brand/google/logo.svg'),
                  label: Text(
                    "Entrar com Google",
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
