import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:minha_saude_frontend/app/ui/view_models/auth/register_view_model.dart';
import 'package:minha_saude_frontend/app/ui/views/auth/layouts/login_form_layout.dart';
import 'package:watch_it/watch_it.dart';

// Wrapper for RegisterView to handle ViewModel disposal
class RegisterView extends WatchingStatefulWidget {
  const RegisterView(this.viewModel, {super.key});

  final RegisterViewModel viewModel;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  RegisterViewModel get viewModel => widget.viewModel;
  @override
  void initState() {
    super.initState();

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
      final registerResult = registerCommand.result;

      if (registerCommand.isSuccess) {
        final redirectPath = registerResult!.getOrThrow();
        if (mounted && redirectPath != null) {
          context.go(redirectPath);
        }
        registerCommand.clearResult();
        return;
      }

      if (registerCommand.isError) {
        final error = registerResult!.tryGetError()!;
        _showErrorSnack(error.toString());
        registerCommand.clearResult();
        return;
      }

      setState(() {});
    } catch (e) {
      Logger("RegisterView").severe("Ocorreu um erro desconhecido: $e");
      _showErrorSnack("Ocorreu um erro desconhecido.");
    }
  }

  void _showErrorSnack(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      backgroundColor: Theme.of(context).colorScheme.error,
    );

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
    final bool isExecutingRegister = viewModel.registerCommand.isExecuting;

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
                    mask: '+## (##) #####-####',
                    filter: {"#": RegExp(r'[0-9]')},
                    type: MaskAutoCompletionType.lazy,
                  ),
                ],
              ),
              FilledButton(
                onPressed: isExecutingRegister
                    ? null
                    : () => viewModel.registerCommand.execute(),
                style: FilledButton.styleFrom(
                  backgroundColor: isExecutingRegister
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.12)
                      : Theme.of(context).primaryColor,
                  foregroundColor: isExecutingRegister
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.38)
                      : Theme.of(context).colorScheme.onPrimary,
                ),
                child: isExecutingRegister
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
