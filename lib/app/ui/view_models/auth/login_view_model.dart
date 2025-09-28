import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/google_login_action.dart';
import 'package:minha_saude_frontend/config/router/app_routes.dart';
import 'package:minha_saude_frontend/utils/command.dart';
import 'package:multiple_result/multiple_result.dart';

class LoginViewModel {
  LoginViewModel(this._authRepository, this._googleLoginAction) {
    loginWithGoogle = Command0(_loginWithGoogle);
  }

  final AuthRepository _authRepository;
  final GoogleLoginAction _googleLoginAction;
  final _log = Logger("LoginViewModel");

  /// Command to initiate Google login, returns an app route path to redirect to
  /// Rebuild Widget when this notifies
  /// If result is error then display Snackbar and clear result
  /// If result is success, then use context.go to redirect
  late Command0 loginWithGoogle;

  Future<Result<String, Exception>> _loginWithGoogle() async {
    try {
      final loginResult = await _googleLoginAction.execute();

      if (loginResult.isError()) {
        return Result.error(loginResult.tryGetError()!);
      }

      final response = loginResult.getOrThrow();

      // Set redirect path based on registration status
      return response.isRegistered
          ? Result.success(AppRoutes.home)
          : Result.success(AppRoutes.tos);
    } catch (e) {
      _log.severe(e);
      return Result.error(
        Exception("Ocorreu um erro desconhecido. Por favor, tente novamente"),
      );
    }
  }

  /// Logout user by clearing all tokens and state
  Future<void> logout() async {
    try {
      // Clear all tokens and state through auth repository
      await _authRepository.logout();
    } catch (e) {
      _log.warning("Erro durante logout: $e");
    }
  }

  void clearErrorMessages() {
    loginWithGoogle.clearResult();
  }
}

enum LoginStatus { initial, loading, error, authenticated, needsRegistration }
