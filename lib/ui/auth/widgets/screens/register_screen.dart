import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/ui/auth/view_model/register_screen_view_model.dart';
import 'package:minha_saude_frontend/ui/auth/widgets/layouts/login_form_layout.dart';

class RegisterScreen extends StatelessWidget {
  final RegisterScreenViewModel viewModel;

  const RegisterScreen({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return LoginFormLayout(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(
              'Vamos concluir seu cadastro',
              style: theme.textTheme.titleLarge,
            ),
            Text(
              'Por favor, preencha os campos abaixo',
              style: theme.textTheme.bodyLarge,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'CPF',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.datetime,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            ElevatedButton(
              onPressed: () {
                // Add your button logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Confirmar cadastro'),
            ),
          ],
        ),
      ),
    );
  }
}
