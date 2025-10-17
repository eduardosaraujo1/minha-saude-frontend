import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/session/session_repository.dart';

class RegisterAction {
  RegisterAction({
    required SessionRepository sessionRepository,
    required AuthRepository authRepository,
  }) : _sessionRepository = sessionRepository,
       _authRepository = authRepository;

  final SessionRepository _sessionRepository;
  final AuthRepository _authRepository;
  final Logger _log = Logger("RegisterAction");

  Future<Result<void, RegisterException>> execute({
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

      // Sanitize fields
      nome = nome.trim();
      cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
      telefone = telefone.replaceAll(RegExp(r'[^0-9]'), '');

      if (nome.isEmpty || cpf.isEmpty || telefone.isEmpty) {
        return Result.error(
          UnexpectedRegisterException("Todos os campos são obrigatórios."),
        );
      }

      // Attempt registration
      final result = await _authRepository.register(
        nome: nome,
        cpf: cpf,
        dataNascimento: dataNascimento,
        telefone: telefone,
        registerToken: registerToken,
      );

      if (result.isError()) {
        _log.severe("Registration failed: ", result.tryGetError()!);
        return Result.error(
          UnexpectedRegisterException(
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
        UnexpectedRegisterException(
          "Ocorreu um erro desconhecido durante o processo de registro",
        ),
      );
    }
  }
}

abstract class RegisterException implements Exception {
  final String message;
  RegisterException(this.message);

  @override
  String toString() => 'RegisterException: $message';
}

class UnexpectedRegisterException extends RegisterException {
  UnexpectedRegisterException(super.message);
}

class ExpiredLoginException extends RegisterException {
  ExpiredLoginException(super.message);
}
