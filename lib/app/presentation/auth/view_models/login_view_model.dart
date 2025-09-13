import 'package:flutter/foundation.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/shared/repositories/token_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final TokenRepository tokenRepository;

  LoginStatus _status = LoginStatus.initial;
  String? _errorMessage;
  bool _isLoading = false;

  LoginViewModel(this.authRepository, this.tokenRepository);

  LoginStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    _status = LoginStatus.loading;
    notifyListeners();

    try {
      // Use the new googleLogin method
      final result = await authRepository.googleLogin();

      if (result.isError()) {
        _status = LoginStatus.error;
        _errorMessage =
            "Não foi possível fazer login com o Google. Tente novamente mais tarde.";
      } else {
        final signInResult = result.getOrThrow();

        // Store token in local storage if received
        if (signInResult.sessionToken != null) {
          final tokenResult = await tokenRepository.setToken(
            signInResult.sessionToken!,
          );
          if (tokenResult.isError()) {
            _status = LoginStatus.error;
            _errorMessage = "Falha ao salvar token de autenticação.";
            return;
          }
        }

        // After successful login, check registration status
        final isRegistered = await authRepository.isRegistered();

        if (!isRegistered) {
          _status = LoginStatus.needsRegistration;
        } else if (signInResult.sessionToken != null) {
          _status = LoginStatus.authenticated;
        } else {
          _status = LoginStatus.error;
          _errorMessage = "Ocorreu um erro desconhecido.";
        }
      }
    } catch (e) {
      _status = LoginStatus.error;
      _errorMessage = "Ocorreu um erro desconhecido.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearErrorMessages() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Logout user by clearing token and registration status
  Future<void> logout() async {
    try {
      // Clear token from storage
      await tokenRepository.removeToken();

      // Clear registration status through auth repository
      await authRepository.signOut();

      // Update UI state
      _status = LoginStatus.initial;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Erro durante logout: $e";
      notifyListeners();
    }
  }
}

// ...existing code...

enum LoginStatus { initial, loading, error, authenticated, needsRegistration }
