import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../routing/routes.dart';
import '../view_models/register_view_model.dart';
import 'layouts/login_form_layout.dart';

class RegisterView extends StatefulWidget {
  const RegisterView(this.viewModel, {super.key});

  final RegisterViewModel viewModel;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final RegisterViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = widget.viewModel;
    viewModel.registerCommand.addListener(_onUpdate);
  }

  @override
  void dispose() {
    viewModel.registerCommand.removeListener(_onUpdate);
    viewModel.dispose();

    super.dispose();
  }

  void _onUpdate() {
    try {
      final registerCommand = viewModel.registerCommand;
      final registerResult = registerCommand.value;

      if (registerResult == null) {
        // Initial state
        return;
      }

      if (registerResult.isSuccess()) {
        final registerStatus = registerResult.tryGetSuccess()!;
        if (mounted) {
          switch (registerStatus) {
            case RegisterResult.success:
              context.go(Routes.home);
              break;
            case RegisterResult.tokenExpired:
              _showSnack(
                "Login expirado. Faça login novamente para continuar.",
              );
              context.go(Routes.login);
              break;
          }
        }
        return;
      }

      if (registerResult.isError()) {
        final error = registerResult.tryGetError()!;
        _showSnack("Erro: ${error.toString()}");
        return;
      }
    } catch (e) {
      Logger("RegisterView").severe("Ocorreu um erro desconhecido: $e");
      _showSnack("Ocorreu um erro desconhecido.");
    }
  }

  void _showSnack(String message) {
    final snackBar = SnackBar(content: Text(message));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _triggerBirthDatePicker(BuildContext context) async {
    final dtNascimentoController = viewModel.form.dataNascimentoController;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      dtNascimentoController.value = TextEditingValue(
        text: "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = viewModel.form;

    return LoginFormLayout(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Form(
          key: form.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                'Vamos concluir seu cadastro',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Por favor, preencha os campos abaixo',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              TextFormField(
                controller: form.nomeController,
                validator: form.validateNome,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: form.cpfController,
                validator: form.validateCpf,
                decoration: InputDecoration(
                  hint: Text(
                    "123.456.789-10",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                controller: form.dataNascimentoController,
                validator: form.validateDtNascimento,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () => _triggerBirthDatePicker(context),
              ),
              TextFormField(
                controller: form.telefoneController,
                validator: form.validateTelefone,
                decoration: InputDecoration(
                  hint: Text(
                    "+55 11 98765-4321",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  MaskTextInputFormatter(
                    mask: '(##) #####-####',
                    filter: {"#": RegExp(r'[0-9]')},
                    type: MaskAutoCompletionType.lazy,
                  ),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: viewModel.registerCommand.isExecuting,
                builder: (context, isExecuting, child) {
                  return FilledButton(
                    onPressed: isExecuting
                        ? null
                        : () => viewModel.registerCommand.execute(),
                    child: isExecuting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.38),
                              ),
                            ),
                          )
                        : const Text('Confirmar cadastro'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
