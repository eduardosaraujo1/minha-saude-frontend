import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/shared/repositories/token_repository.dart';
import 'package:minha_saude_frontend/app/di/get_it.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final TokenRepository tokenRepository;

  String? _errorMessage;
  bool _isLoading = false;

  LoginViewModel(this.authRepository, this.tokenRepository);

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await authRepository.googleLogin();

      if (result.isError()) {
        _errorMessage = result.tryGetError()!.toString();
      } else {
        final response = result.getOrThrow();

        // Handle response based on registration status
        if (response.isRegistered) {
          // User is fully registered - navigate to main app
          getIt<GoRouter>().go("/");
        } else {
          // User needs to complete registration - navigate to TOS
          getIt<GoRouter>().go("/tos");
        }
      }
    } catch (e) {
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
      notifyListeners();
    } catch (e) {
      _errorMessage = "Erro durante logout: $e";
      notifyListeners();
    }
  }
}

enum LoginStatus { initial, loading, error, authenticated, needsRegistration }
