import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/user_register_model/user_register_model.dart';
import 'package:minha_saude_frontend/config/router/routes.dart';
import 'package:minha_saude_frontend/utils/command.dart';
import 'package:multiple_result/multiple_result.dart';

class RegisterViewModel {
  RegisterViewModel(this._authRepository) {
    registerCommand = Command0(_registerUser);
  }

  final RegisterForm form = RegisterForm();
  final AuthRepository _authRepository;
  final Logger _log = Logger("RegisterViewModel");

  // final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  // final ValueNotifier<String?> redirectTo = ValueNotifier(null);
  // final ValueNotifier<bool> isLoading = ValueNotifier(false);

  late Command0<String?, Exception> registerCommand;

  /// Register user with current form data
  Future<Result<String?, Exception>> _registerUser() async {
    try {
      // Validar form antes de executar qualquer lógica
      if (!form.validate()) {
        return Result.success(null);
      }

      // Gerenciar erros para token de registro
      // final regTokenResult = _authRepository.getRegisterToken();
      final registerToken = _authRepository.getRegisterToken();
      if (registerToken == null) {
        _log.fine("Token de registro definido como nulo.");
        return Result.error(
          Exception("Token de registro expirado. Faça login novamente."),
        );
      }

      // Iniciar registro
      final result = await _authRepository.register(
        UserRegisterModel(
          nome: form.nomeController.text.trim(),
          cpf: form.cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          dataNascimento: _parseDate(form.dataNascimentoController.text.trim()),
          telefone: form.telefoneController.text.trim(),
          registerToken: registerToken,
        ),
      );

      if (result.isError()) {
        return Result.error(
          Exception(
            "Ocorreu um erro desconhecido durante o processo de registro",
          ),
        );
      }

      return Result.success(Routes.home);
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

enum RegisterState { initial, loading, success, error, tokenExpired }

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
