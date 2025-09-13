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
      final result = await authRepository.googleLogin();

      if (result.isError()) {
        _status = LoginStatus.error;
        _errorMessage = result.tryGetError()!.toString();
      } else {
        final response = result.getOrThrow();

        // Handle response based on registration status
        if (response.isRegistered) {
          // User is fully registered - session token is handled by repository
          _status = LoginStatus.authenticated;
        } else {
          // User needs to complete registration - register token is handled by repository
          _status = LoginStatus.needsRegistration;
        }
      }
    } catch (e) {
      _status = LoginStatus.error;
      _errorMessage = "Ocorreu um erro desconhecido: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearErrorMessages() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Logout user by clearing all tokens and state
  Future<void> logout() async {
    try {
      // Clear all tokens and state through auth repository
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
