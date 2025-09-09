import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:minha_saude_frontend/old/features/auth/ui/view_models/register_screen_view_model.dart';
import 'package:minha_saude_frontend/old/features/auth/ui/views/layouts/login_form_layout.dart';

class RegisterScreen extends StatelessWidget {
  final RegisterScreenViewModel viewModel;

  const RegisterScreen({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return LoginFormLayout(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Form(
          key: viewModel.formKey,
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
                controller: viewModel.nomeController,
                validator: viewModel.validateNome,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: viewModel.cpfController,
                validator: viewModel.validateCpf,
                decoration: InputDecoration(
                  hint: Text(
                    "123.456.789-10",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(0xAA),
                    ),
                  ),
                  labelText: 'CPF',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  MaskTextInputFormatter(
                    mask: '###.###.###-##',
                    filter: {"#": RegExp(r'[0-9]')},
                    type: MaskAutoCompletionType.lazy,
                  ),
                ],
              ),
              TextFormField(
                controller: viewModel.dataNascimentoController,
                validator: viewModel.validateDtNascimento,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () => triggerBirthDatePicker(context),
              ),
              TextFormField(
                controller: viewModel.telefoneController,
                validator: viewModel.validateTelefone,
                decoration: InputDecoration(
                  hint: Text(
                    "+55 11 98765-4321",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(0xAA),
                    ),
                  ),
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  MaskTextInputFormatter(
                    mask: '+## (##) #####-####',
                    filter: {"#": RegExp(r'[0-9]')},
                    type: MaskAutoCompletionType.lazy,
                  ),
                ],
              ),
              FilledButton(
                onPressed: () {
                  viewModel.registerUser();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Confirmar cadastro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void triggerBirthDatePicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      viewModel.dataNascimentoController.value = TextEditingValue(
        text: "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
      );
    }
  }
}
