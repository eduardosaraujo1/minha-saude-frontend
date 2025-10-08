import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/actions/auth/register_action.dart';

class RegisterViewModel {
  RegisterViewModel({required RegisterAction registerAction})
    : _registerAction = registerAction {
    registerCommand = Command.createAsyncNoParam(
      _registerUser,
      initialValue: null,
    );
  }

  final RegisterAction _registerAction;
  final Logger _log = Logger("RegisterViewModel");

  final RegisterForm _form = RegisterForm();

  RegisterForm get form => _form;

  late Command<void, Result<RegisterResult, Exception>?> registerCommand;

  /// Register user with current form data
  Future<Result<RegisterResult, Exception>?> _registerUser() async {
    try {
      // Validar form antes de executar qualquer lógica
      if (!form.validate()) {
        return null;
      }

      // Iniciar registro
      final result = await _registerAction.execute(
        nome: form.nomeController.text.trim(),
        cpf: form.cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        dataNascimento: _parseDate(form.dataNascimentoController.text.trim()),
        telefone: form.telefoneController.text.trim(),
      );

      if (result.isError()) {
        final error = result.tryGetError()!;

        if (error is ExpiredLoginException) {
          // TODO: display snackbar "Login expirado. Faça login novamente para continuar."
          return Result.success(RegisterResult.tokenExpired);
        }

        return Result.error(result.tryGetError()!);
      }

      return Result.success(RegisterResult.success);
    } catch (e) {
      _log.severe("Ocorreu um erro desconhecido durante o registro: $e");
      return Result.error(
        Exception("Ocorreu um erro desconhecido durante o registro."),
      );
    }
  }

  /// Dispose form controllers
  void dispose() {
    form.dispose();
  }

  /// Parse date from DD/MM/YYYY format
  DateTime _parseDate(String dateText) {
    final parts = dateText.split('/');

    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } else {
      throw FormatException('Data de nascimento inválida');
    }
  }
}

enum RegisterResult { success, tokenExpired }

class RegisterForm {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final cpfController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final telefoneController = TextEditingController();

  /// Validates the form and returns true if valid
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  void onFormChanged(VoidCallback callback) {
    nomeController.addListener(callback);
    cpfController.addListener(callback);
    dataNascimentoController.addListener(callback);
    telefoneController.addListener(callback);
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
    final regex = RegExp(r'^\+55 \(\d{2}\) \d{5}-\d{4}$');
    if (!regex.hasMatch(value ?? '')) {
      return 'Telefone deve estar no formato +55 (XX) XXXXX-XXXX';
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
