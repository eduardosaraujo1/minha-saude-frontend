import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth_repository.dart';

class ContaViewModel {
  final AuthRepository authRepository;

  final isLinkingContaGoogle = ValueNotifier<bool>(false);
  final googleVinculado = ValueNotifier<bool>(false);
  final redirectTo = ValueNotifier<String?>(null);

  ContaViewModel(this.authRepository);

  void signout() async {
    await authRepository.signOut();
    redirectTo.value = '/login';
  }

  Future<void> linkGoogleAccount() async {
    isLinkingContaGoogle.value = true;
    await Future.delayed(Duration(seconds: 2));
    googleVinculado.value = true;
    isLinkingContaGoogle.value = false;
  }
}
