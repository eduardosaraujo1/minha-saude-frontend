import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../data/repositories/session/session_repository.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../models/auth/login_response/login_result.dart';

class LoginWithGoogle {
  LoginWithGoogle({
    required AuthRepository authRepository,
    required SessionRepository sessionRepository,
  }) : _authRepository = authRepository,
       _sessionRepository = sessionRepository;

  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;
  final _log = Logger("LoginWithGoogleAction");

  Future<Result<LoginResult, Exception>> execute() async {
    try {
      // Get Google server auth token
      final googleTokenResult = await _authRepository.getGoogleServerToken();
      if (googleTokenResult.isError()) {
        _log.severe(
          "Failed to get Google server token",
          googleTokenResult.tryGetError(),
        );
        return Result.error(
          Exception("Não foi possível autenticar-se com o Google."),
        );
      }
      final googleToken = googleTokenResult.getOrThrow();

      // Use googleToken to login with google
      final loginResult = await _authRepository.loginWithGoogle(googleToken);
      if (loginResult.isError()) {
        _log.severe("Login with Google failed: ${loginResult.tryGetError()}");
        return Result.error(
          Exception("Não foi possível fazer login com o Google."),
        );
      }
      final loginResponse = loginResult.getOrThrow();

      // Store token based on login response type
      switch (loginResponse) {
        case SuccessfulLoginResult():
          final storeResult = await _storeAuthToken(loginResponse);
          // Error if auth storage failed
          if (storeResult.isError()) {
            _log.severe("Login was successful, but couldn't store auth token");
            return Error(
              Exception("Não foi possível salvar o token de autenticação."),
            );
          }
          break;
        case NeedsRegistrationLoginResult():
          // Error if registration token storage failed
          final storeResult = await _storeRegisterToken(loginResponse);
          if (storeResult.isError()) {
            _log.severe(
              "Login was successful, but couldn't store registration token",
            );
            return Error(
              Exception("Não foi possível salvar o token de registro."),
            );
          }
          break;
      }

      return Success(loginResponse);
    } catch (e) {
      _log.severe("Ocorreu um erro desconhecido: ", e);
      return Result.error(
        Exception("Ocorreu um erro desconhecido. Por favor, tente novamente."),
      );
    }
  }

  Future<Result<void, Exception>> _storeAuthToken(
    SuccessfulLoginResult loginResponse,
  ) async {
    final tokenResult = await _sessionRepository.setAuthToken(
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
    _sessionRepository.clearRegisterToken();

    return Success(null);
  }

  Future<Result<void, Exception>> _storeRegisterToken(
    NeedsRegistrationLoginResult loginResponse,
  ) async {
    _sessionRepository.setRegisterToken(loginResponse.registerToken);

    // REMOVED: loginWithGoogle should not concern itself with this, that's the responsability of the login repository
    // Clear any existing auth token that might be set from a previous login
    // final clearAuthResult = await _sessionRepository.clearAuthToken();
    // if (clearAuthResult.isError()) {
    //   return Result.error(
    //     Exception("Não foi possível limpar o token de autenticação atual."),
    //   );
    // }

    return Success(null);
  }
}
