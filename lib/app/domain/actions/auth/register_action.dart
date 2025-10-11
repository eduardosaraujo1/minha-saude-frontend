import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/session/session_repository.dart';
import '../../models/auth/user_register_model/user_register_model.dart';

class RegisterAction {
  RegisterAction({
    required SessionRepository sessionRepository,
    required AuthRepository authRepository,
  }) : _sessionRepository = sessionRepository,
       _authRepository = authRepository;

  final SessionRepository _sessionRepository;
  final AuthRepository _authRepository;
  final Logger _log = Logger("RegisterAction");

  Future<Result<void, Exception>> execute({
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String telefone,
  }) async {
    try {
      final registerToken = _sessionRepository.getRegisterToken();
      if (registerToken == null) {
        _log.severe("Token de registro definido como nulo.");
        return Result.error(
          ExpiredLoginException(
            "Login expirado. Faça login novamente para continuar.",
          ),
        );
      }

      final result = await _authRepository.register(
        UserRegisterModel(
          nome: nome,
          cpf: cpf,
          dataNascimento: dataNascimento,
          telefone: telefone,
          registerToken: registerToken,
        ),
      );

      if (result.isError()) {
        _log.severe("Registration failed: ", result.tryGetError()!);
        return Result.error(
          Exception(
            "Ocorreu um erro desconhecido durante o processo de registro",
          ),
        );
      }

      final sessionToken = result.getOrThrow();

      // Clear register token since registration is complete
      _sessionRepository.clearRegisterToken();

      // Store session token
      await _sessionRepository.setAuthToken(sessionToken);

      return Result.success(null);
    } catch (e) {
      _log.severe("Unexpected error: ", e);
      return Result.error(
        Exception(
          "Ocorreu um erro desconhecido durante o processo de registro",
        ),
      );
    }
  }
}

class ExpiredLoginException implements Exception {
  ExpiredLoginException(this.message);

  final String message;

  @override
  String toString() => message;
}
