import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/shared/repositories/token_repository.dart';
import 'package:command_it/command_it.dart';

class DocumentListViewModel extends ChangeNotifier {
  DocumentListViewModel(this.authRepository, this.tokenRepository) {
    cmdLogout = Command.createAsyncNoParam<bool>(_logout, initialValue: false);
  }

  final AuthRepository authRepository;
  final TokenRepository tokenRepository;

  late final Command<void, bool> cmdLogout;

  Future<bool> _logout() async {
    await tokenRepository.removeToken();
    await authRepository.signOut();

    return true;
  }
}
