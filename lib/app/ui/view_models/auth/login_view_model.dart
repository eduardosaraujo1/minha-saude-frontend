import 'package:flutter/foundation.dart';
import 'package:minha_saude_frontend/app/data/repositories/_deprecated/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/token_repository.dart';

class LoginViewModel {
  final AuthRepository authRepository;

  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> redirectTo = ValueNotifier(null);

  LoginViewModel(this.authRepository);

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await authRepository.loginWithGoogle();

      if (result.isError()) {
        errorMessage.value = result.tryGetError()!.toString();
      } else {
        final response = result.getOrThrow();

        // Set redirect path based on registration status
        if (response.isRegistered) {
          redirectTo.value = "/";
        } else {
          redirectTo.value = "/tos";
        }
      }
    } catch (e) {
      errorMessage.value = "Ocorreu um erro desconhecido: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void clearErrorMessages() {
    errorMessage.value = null;
  }

  /// Logout user by clearing all tokens and state
  Future<void> logout() async {
    try {
      // Clear all tokens and state through auth repository
      await authRepository.signOut();
    } catch (e) {
      errorMessage.value = "Erro durante logout: $e";
    }
  }
}

enum LoginStatus { initial, loading, error, authenticated, needsRegistration }
