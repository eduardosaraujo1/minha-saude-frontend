import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile_repository.dart';

class EditTelefoneViewModel {
  final ProfileRepository profileRepository;

  final telefoneController = TextEditingController();
  final isLoading = ValueNotifier(false);
  final errorMessage = ValueNotifier<String?>(null);

  EditTelefoneViewModel(this.profileRepository) {
    _init();
  }

  _init() async {
    isLoading.value = true;
    final result = await profileRepository.getUserProfile();
    if (result.isSuccess()) {
      telefoneController.text = result.getOrThrow().telefone;
    } else {
      errorMessage.value = result.tryGetError()?.toString();
    }
    isLoading.value = false;
  }

  bool _isValidPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Brazilian phone number should have 10 or 11 digits (with area code)
    // Format examples: +55 11 95149-0211, (11) 95149-0211, 11 95149-0211
    return digitsOnly.length >= 10 && digitsOnly.length <= 13;
  }

  Future<bool> saveTelefone() async {
    final telefone = telefoneController.text.trim();

    if (telefone.isEmpty) {
      errorMessage.value = "Telefone não pode estar vazio";
      return false;
    }

    if (!_isValidPhoneNumber(telefone)) {
      errorMessage.value = "Formato de telefone inválido";
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final result = await profileRepository.updateTelefone(telefone);

    isLoading.value = false;

    if (result.isSuccess()) {
      return true;
    } else {
      errorMessage.value =
          result.tryGetError()?.toString() ?? "Erro ao salvar telefone";
      return false;
    }
  }

  void dispose() {
    telefoneController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
