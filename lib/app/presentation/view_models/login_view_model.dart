import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/domain/actions/google_login_action.dart';

abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginRedirectState extends LoginState {
  final String redirectTo;

  LoginRedirectState(this.redirectTo);
}

class LoginErrorState extends LoginState {
  final String message;

  LoginErrorState(this.message);
}

class LoginViewModel extends ChangeNotifier {
  final GoogleLoginAction googleLoginAction;

  LoginState _state = LoginInitialState();
  LoginState get state => _state;

  LoginViewModel(this.googleLoginAction);

  Future<void> loginWithGoogle() async {
    _state = LoginLoadingState();
    notifyListeners();

    try {
      final result = await googleLoginAction.execute();

      switch (result) {
        case LoginResult.success:
          _state = LoginRedirectState('documents');
        case LoginResult.needsRegistration:
          _state = LoginRedirectState('tos');
        case LoginResult.failure:
          _state = LoginErrorState("Falha ao realizar login. Tente novamente.");
        case LoginResult.canceled:
          _state = LoginErrorState(
            "Login cancelado pelo usuário ou pelo Google.",
          );
      }
    } catch (e) {
      _state = LoginErrorState("Ocorreu um erro desconhecido: $e");
    } finally {
      notifyListeners();
    }
  }

  void clearErrorMessages() {
    _state = LoginInitialState();
  }
}
