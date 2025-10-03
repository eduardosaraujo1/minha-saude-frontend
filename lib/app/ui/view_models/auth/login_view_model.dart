import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/login_response/login_response.dart';
import 'package:minha_saude_frontend/app/routing/routes.dart';
import 'package:minha_saude_frontend/app/utils/command.dart';
import 'package:multiple_result/multiple_result.dart';

class LoginViewModel {
  LoginViewModel(this._authRepository) {
    loginWithGoogle = Command0(_loginWithGoogle);
  }

  final AuthRepository _authRepository;
  final _log = Logger("LoginViewModel");

  /// Command to initiate Google login, returns an app route path to redirect to
  /// Rebuild Widget when this notifies
  /// If result is error then display Snackbar and clear result
  /// If result is success, then use context.go to redirect
  late Command0<String?, Exception> loginWithGoogle;

  Future<Result<String?, Exception>> _loginWithGoogle() async {
    try {
      final googleTokenResult = await _authRepository.getGoogleServerToken();

      if (googleTokenResult.isError()) {
        return Result.error(
          Exception("Não foi possível autenticar-se com o Google."),
        );
      }

      final googleToken = googleTokenResult.getOrThrow();

      // Continue with the login process using the obtained token
      final loginResult = await _authRepository.loginWithGoogle(googleToken);

      if (loginResult.isError()) {
        return Result.error(
          Exception("Não foi possível fazer login com o Google."),
        );
      }

      if (loginResult.isError()) {
        return Result.error(loginResult.tryGetError()!);
      }

      final response = loginResult.getOrThrow();

      // Set redirect path based on registration status
      return response is SuccessfulLoginResponse
          ? Result.success(Routes.home)
          : Result.success(Routes.tos);
    } catch (e) {
      _log.severe(e);
      return Result.error(
        Exception("Ocorreu um erro desconhecido. Por favor, tente novamente."),
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
}

enum LoginStatus { initial, loading, error, authenticated, needsRegistration }
