import 'package:flutter/material.dart';

class RegisterScreenViewModel extends RegisterFormState {
  RegisterScreenViewModel() {
    // onFormChanged(checkFormValidity);
  }

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  /// Register user with current form data
  Future<bool> registerUser() async {
    return formKey.currentState?.validate() ?? false;
    // TODO: integrate with AuthRepository to register user
    // TODO: use command_it for better state management
  }

  /// Parse date from DD/MM/YYYY format
  // DateTime? _parseDate(String dateText) {
  //   try {
  //     final parts = dateText.split('/');
  //     if (parts.length == 3) {
  //       final day = int.parse(parts[0]);
  //       final month = int.parse(parts[1]);
  //       final year = int.parse(parts[2]);
  //       return DateTime(year, month, day);
  //     }
  //   } catch (e) {
  //     // Invalid date format
  //   }
  //   return null;
  // }

  @override
  void dispose() {
    super.dispose();
  }
}

enum RegisterState { initial, loading, success, error }

class RegisterFormState {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final cpfController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final telefoneController = TextEditingController();

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
