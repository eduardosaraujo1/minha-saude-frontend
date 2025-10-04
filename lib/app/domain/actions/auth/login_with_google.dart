import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../models/auth/login_response/login_result.dart';
import '../action.dart';

class LoginWithGoogle implements Action {
  LoginWithGoogle(this._authRepository);

  final AuthRepository _authRepository;
  final _log = Logger("LoginWithGoogleAction");

  @override
  Future<Result<RedirectResponse, Exception>> execute() async {
    try {
      // Get Google server auth token
      final googleTokenResult = await _authRepository.getGoogleServerToken();
      if (googleTokenResult.isError()) {
        return Result.error(
          Exception("Não foi possível autenticar-se com o Google."),
        );
      }
      final googleToken = googleTokenResult.getOrThrow();

      // Use googleToken to login with google
      final loginResult = await _authRepository.loginWithGoogle(googleToken);
      if (loginResult.isError()) {
        _log.warning("Login with Google failed: ${loginResult.tryGetError()}");
        return Result.error(
          Exception("Não foi possível fazer login com o Google."),
        );
      }
      final loginResponse = loginResult.getOrThrow();

      // Decide if login token should be stored or if user needs to register
      return switch (loginResponse) {
        SuccessfulLoginResult() => await _setAuthenticatedState(loginResponse),
        NeedsRegistrationLoginResult() => await _setRegisteringState(
          loginResponse,
        ),
      };
    } catch (e) {
      _log.severe(e);
      return Result.error(
        Exception("Ocorreu um erro desconhecido. Por favor, tente novamente."),
      );
    }
  }

  Future<Result<RedirectResponse, Exception>> _setAuthenticatedState(
    SuccessfulLoginResult loginResponse,
  ) async {
    final tokenResult = await _authRepository.setAuthToken(
      loginResponse.sessionToken,
    );

    if (tokenResult.isError()) {
      _log.severe(
        "Authentication was successful, but couldn't store auth token",
      );
      return Result.error(
        Exception("Não foi possível salvar as credenciais de autenticação."),
      );
    }

    // Clear any registration token that might be set from a previous registration attempt
    _authRepository.clearRegisterToken(null);

    return Result.success(RedirectResponse.toHome);
  }

  Future _setRegisteringState(
    NeedsRegistrationLoginResult loginResponse,
  ) async {
    _authRepository.setRegisterToken(loginResponse.registerToken);

    final clearAuthResult = await _authRepository.clearAuthToken();
    if (clearAuthResult.isError()) {
      return Result.error(
        Exception("Não foi possível limpar o token de autenticação atual."),
      );
    }

    return Result.success(RedirectResponse.toRegister);
  }
}

enum RedirectResponse { toRegister, toHome }
