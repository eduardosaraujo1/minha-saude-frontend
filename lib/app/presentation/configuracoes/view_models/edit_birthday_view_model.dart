import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/profile/repositories/profile_repository.dart';

class EditBirthdayViewModel {
  final ProfileRepository profileRepository;

  DateTime? _selectedDate;
  final isLoading = ValueNotifier(false);
  final errorMessage = ValueNotifier<String?>(null);

  DateTime? get selectedDate => _selectedDate;

  EditBirthdayViewModel(this.profileRepository) {
    _init();
  }

  _init() async {
    isLoading.value = true;
    final result = await profileRepository.getUserProfile();
    if (result.isSuccess()) {
      final user = result.getOrThrow();
      // Parse birthDate from string format (DD/MM/YYYY)
      try {
        final parts = user.birthDate.split('/');
        if (parts.length == 3) {
          _selectedDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e) {
        errorMessage.value = "Erro ao carregar data de nascimento";
      }
    } else {
      errorMessage.value = result.tryGetError()?.toString();
    }
    isLoading.value = false;
  }

  void updateSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<bool> saveBirthDate() async {
    if (_selectedDate == null) {
      errorMessage.value = "Data de nascimento deve ser selecionada";
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final formattedDate = formatDate(_selectedDate!);
    final result = await profileRepository.updateBirthDate(formattedDate);

    isLoading.value = false;

    if (result.isSuccess()) {
      return true;
    } else {
      errorMessage.value =
          result.tryGetError()?.toString() ??
          "Erro ao salvar data de nascimento";
      return false;
    }
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
  }
}
