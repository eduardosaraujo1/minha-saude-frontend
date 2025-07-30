import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/ui/auth/view_model/email_input_view_model.dart';
import 'package:minha_saude_frontend/ui/auth/widgets/layouts/login_form_layout.dart';

class EmailInputScreen extends StatelessWidget {
  final EmailInputViewModel viewModel;

  const EmailInputScreen({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return LoginFormLayout(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Digite seu E-mail",
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: viewModel.emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'exemplo@email.com',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: viewModel.validateEmail,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {
                  if (viewModel.formKey.currentState?.validate() ?? false) {
                    // TODO: Handle continue action
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: theme.colorScheme.primary,
                ),
                child: Text(
                  "Continuar",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
