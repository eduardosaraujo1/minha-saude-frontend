import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/login_with_google.dart';
import 'package:minha_saude_frontend/app/routing/routes.dart';
import 'package:minha_saude_frontend/app/utils/command.dart';
import 'package:multiple_result/multiple_result.dart';

class LoginViewModel {
  LoginViewModel(this._authRepository, this._loginWithGoogleAction) {
    loginWithGoogle = Command0(_loginWithGoogle);
  }

  final AuthRepository _authRepository;
  final LoginWithGoogle _loginWithGoogleAction;
  final _log = Logger("LoginViewModel");

  /// Command to initiate Google login, returns an app route path to redirect to
  /// Rebuild Widget when this notifies
  /// If result is error then display Snackbar and clear result
  /// If result is success, then use context.go to redirect
  late Command0<String?, Exception> loginWithGoogle;

  /// Perform login with Google action
  /// Returns a nullable string that is the route to redirect to
  Future<Result<String?, Exception>> _loginWithGoogle() async {
    try {
      final Exception defaultErr = Exception(
        "Não foi possível fazer login com o Google.",
      );

      final redirectResult = await _loginWithGoogleAction.execute();
      if (redirectResult.isError()) {
        final err = redirectResult.tryGetError()!;
        _log.warning("Login with Google failed: $err");
        return Result.error(defaultErr);
      }

      return switch (redirectResult.getOrThrow()) {
        RedirectResponse.toHome => Result.success(Routes.home),
        RedirectResponse.toRegister => Result.success(Routes.register),
      };
    } catch (e) {
      _log.severe("Ocorreu um erro desconhecido:", e);
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
