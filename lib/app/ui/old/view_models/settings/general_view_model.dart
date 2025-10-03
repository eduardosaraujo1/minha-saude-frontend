import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/domain/models/user.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile_repository.dart';

class GeneralViewModel {
  final ProfileRepository profileRepository;

  final user = ValueNotifier<User?>(null);
  final userStatus = ValueNotifier<PageStatus>(PageStatus.initial);

  GeneralViewModel(this.profileRepository) {
    _init();

    profileRepository.addListener(() {
      _init();
    });
  }

  void _init() async {
    userStatus.value = PageStatus.loading;
    final result = await profileRepository.getUserProfile();

    if (result.isError()) {
      userStatus.value = PageStatus.error;
    } else {
      user.value = result.getOrThrow();
      userStatus.value = PageStatus.success;
    }
  }
}

enum PageStatus { initial, loading, success, error }
