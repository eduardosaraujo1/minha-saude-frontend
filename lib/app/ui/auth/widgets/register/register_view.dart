import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/register_view_model.dart';
import 'package:minha_saude_frontend/app/utils/format.dart';

import '../../../../domain/actions/auth/register_action.dart';
import '../layouts/login_form_layout.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.viewModel});

  final RegisterViewModel viewModel;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  RegisterViewModel get viewModel => widget.viewModel;

  final RegisterFormController controller = RegisterFormController();

  void _triggerBirthDatePicker(BuildContext context) async {
    final dtNascimentoController = controller.dataNascimentoController;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      dtNascimentoController.value = TextEditingValue(
        text: "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
      );
    }
  }

  void _submitFormIfValid() {
    if (!controller.validate()) {
      return;
    }

    final date = parseDateString(controller.dataNascimentoController.text);

    if (date.isError()) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ocorreu um erro ao processar a data de nascimento. Tente selecioná-la novamente.',
          ),
        ),
      );
      return;
    }

    viewModel.registerCommand.execute(
      RegisterRequestModel(
        nome: controller.nomeController.text,
        cpf: controller.cpfController.text,
        dataNascimento: date.tryGetSuccess()!,
        telefone: controller.telefoneController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LoginFormLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsetsGeometry.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Form(
          key: controller.formKey,
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
                key: ValueKey('inputNome'),
                controller: controller.nomeController,
                validator: controller.validateNome,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  counterText: "",
                ),
                maxLength: 100,
              ),
              TextFormField(
                key: ValueKey('inputCpf'),
                controller: controller.cpfController,
                validator: controller.validateCpf,
                decoration: InputDecoration(
                  hintText: "123.456.789-10",
                  labelText: 'CPF',
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
                key: ValueKey('inputDataNascimento'),
                controller: controller.dataNascimentoController,
                validator: controller.validateDtNascimento,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () => _triggerBirthDatePicker(context),
              ),
              TextFormField(
                key: ValueKey('inputTelefone'),
                controller: controller.telefoneController,
                validator: controller.validateTelefone,
                decoration: InputDecoration(
                  hintText: "(11) 98765-4321",
                  labelText: 'Telefone',
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
                    key: ValueKey('btnSubmit'),
                    onPressed: isExecuting ? null : _submitFormIfValid,
                    child: isExecuting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onSurface.withValues(alpha: 0.38),
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

class RegisterFormController {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final cpfController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final telefoneController = TextEditingController();

  /// Validates the form and returns true if valid
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu nome';
    }

    return null;
  }

  String? validateDtNascimento(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua data de nascimento';
    }
    return null;
  }

  String? validateCpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu CPF';
    }

    // Remove caracteres não numéricos
    final cpf = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Verifica se o CPF tem 11 dígitos
    if (cpf.length != 11) {
      return 'CPF deve conter 11 dígitos';
    }

    // Verifica se todos os dígitos são iguais (CPF inválido)
    if (RegExp(r'^(.)\1*$').hasMatch(cpf)) {
      return 'CPF inválido';
    }

    // Cálculo dos dígitos verificadores
    int calcularDigito(String base) {
      int soma = 0;
      for (int i = 0; i < base.length; i++) {
        soma += int.parse(base[i]) * (base.length + 1 - i);
      }
      int resto = soma % 11;
      return resto < 2 ? 0 : 11 - resto;
    }

    final digito1 = calcularDigito(cpf.substring(0, 9));
    final digito2 = calcularDigito(cpf.substring(0, 9) + digito1.toString());

    if (cpf.substring(9) != '$digito1$digito2') {
      return 'CPF inválido';
    }

    return null;
  }

  String? validateTelefone(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Por favor, insira seu telefone';
    }

    // Verifica se o telefone segue o formato brasileiro
    final regex = RegExp(r'^\(\d{2}\) (9\d{4}|\d{4})-\d{4}$');
    if (!regex.hasMatch(value ?? '')) {
      return 'Telefone deve estar no formato (XX) XXXX-XXXX ou (XX) 9XXXX-XXXX';
    }

    return null;
  }

  void dispose() {
    nomeController.dispose();
    cpfController.dispose();
    dataNascimentoController.dispose();
    telefoneController.dispose();
  }
}
