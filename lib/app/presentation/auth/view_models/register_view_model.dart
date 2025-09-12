import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/auth/models/user.dart';
import 'package:minha_saude_frontend/app/domain/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterForm form = RegisterForm();
  final IAuthRepository authRepository;

  RegisterViewModel(this.authRepository);

  String? _errorMessage;

  bool _isLoading = false;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;

  /// Register user with current form data
  Future<void> registerUser() async {
    try {
      if (!form.validate()) {
        return;
      }
      _isLoading = true;
      notifyListeners();

      final newUser = User(
        nome: form.nomeController.text.trim(),
        cpf: form.cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        dataNascimento: _parseDate(form.dataNascimentoController.text.trim()),
        telefone: form.telefoneController.text.trim(),
      );

      // Use the new googleRegister method
      final result = await authRepository.register(newUser);

      if (result.isError()) {
        _errorMessage =
            result.tryGetError()?.toString() ?? "Ocorreu um erro desconhecido.";
      } else {
        // Registration successful, cache should be updated automatically
        log("Registration successful");
      }
    } catch (e) {
      log(e.toString());
      _errorMessage = "Ocorreu um erro desconhecido.";
    } finally {
      _isLoading = false;
      notifyListeners();
      // Note: Don't clear error message immediately - let the UI handle it
    }
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

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }
}

enum RegisterState { initial, loading, success, error }

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
