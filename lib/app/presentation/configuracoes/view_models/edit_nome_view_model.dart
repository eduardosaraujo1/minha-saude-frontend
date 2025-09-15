import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/profile/repositories/profile_repository.dart';

class EditNomeViewModel {
  final ProfileRepository profileRepository;

  final nomeController = TextEditingController();
  final isLoading = ValueNotifier(false);
  final errorMessage = ValueNotifier<String?>(null);

  EditNomeViewModel(this.profileRepository) {
    _init();
  }

  _init() async {
    isLoading.value = true;
    final result = await profileRepository.getUserProfile();
    if (result.isSuccess()) {
      nomeController.text = result.getOrThrow().name;
    } else {
      errorMessage.value = result.tryGetError()?.toString();
    }
    isLoading.value = false;
  }

  Future<bool> saveNome() async {
    if (nomeController.text.trim().isEmpty) {
      errorMessage.value = "Nome não pode estar vazio";
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final result = await profileRepository.updateNome(
      nomeController.text.trim(),
    );

    isLoading.value = false;

    if (result.isSuccess()) {
      return true;
    } else {
      errorMessage.value =
          result.tryGetError()?.toString() ?? "Erro ao salvar nome";
      return false;
    }
  }

  void dispose() {
    nomeController.dispose();
  }
}
