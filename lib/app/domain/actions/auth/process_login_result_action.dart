import 'package:multiple_result/multiple_result.dart';

import '../../../data/repositories/session/session_repository.dart';
import '../../models/auth/login_response/login_result.dart';

/// Receives a [LoginResult] and stores the appropriate token in
/// the [SessionRepository].
class ProcessLoginResultAction {
  const ProcessLoginResultAction({required SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository;

  final SessionRepository _sessionRepository;

  Future<Result<void, Exception>> execute(LoginResult loginResult) async {
    try {
      switch (loginResult) {
        case SuccessfulLoginResult():
          return await _storeAuthToken(loginResult.sessionToken);
        case NeedsRegistrationLoginResult():
          return await _storeRegisterToken(loginResult.registerToken);
      }
    } catch (e) {
      return Error(Exception("Falha ao autenticar o usuário: $e"));
    }
  }

  Future<Result<void, Exception>> _storeRegisterToken(
    String registerToken,
  ) async {
    try {
      _sessionRepository.setRegisterToken(registerToken);
      return const Success(null);
    } catch (e) {
      return Error(Exception("Falha ao armazenar o token de registro: $e"));
    }
  }

  Future<Result<void, Exception>> _storeAuthToken(String sessionToken) async {
    try {
      await _sessionRepository.setAuthToken(sessionToken);
      return const Success(null);
    } catch (e) {
      return Error(Exception("Falha ao armazenar o token de sessão: $e"));
    }
  }
}
