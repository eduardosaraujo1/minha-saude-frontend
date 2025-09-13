import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/register_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/layouts/login_form_layout.dart';
import 'package:watch_it/watch_it.dart';

// Wrapper for RegisterView to handle ViewModel disposal
class RegisterView extends StatefulWidget {
  final RegisterViewModel viewModel;
  const RegisterView(this.viewModel, {super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RegisterView(widget.viewModel);
  }
}

class _RegisterView extends WatchingWidget {
  final RegisterViewModel viewModel;
  const _RegisterView(this.viewModel);

  void _onErrorChanged(BuildContext context, String? errorMessage) {
    final errorMessage = viewModel.errorMessage.value;

    if (errorMessage != null) {
      final snackBar = SnackBar(content: Text(errorMessage));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      viewModel.clearErrorMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final form = vm.form;
    final isLoading = watch(vm.isLoading);

    registerChangeNotifierHandler(
      target: vm.errorMessage,
      handler: (context, newValue, cancel) {
        _onErrorChanged(context, newValue.value);
      },
    );

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
                onPressed: isLoading.value
                    ? null
                    : () {
                        vm.registerUser();
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: isLoading.value
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.12)
                      : Theme.of(context).primaryColor,
                  foregroundColor: isLoading.value
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.38)
                      : Theme.of(context).colorScheme.onPrimary,
                ),
                child: isLoading.value
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

  void _triggerBirthDatePicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      viewModel.form.dataNascimentoController.value = TextEditingValue(
        text: "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
      );
    }
  }
}
