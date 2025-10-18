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

  Future<Result<void, RegisterException>> execute(
    RegisterRequestModel requestModel,
  ) async {
    try {
      final registerToken = _sessionRepository.getRegisterToken();

      if (registerToken == null || registerToken.isEmpty) {
        _log.severe("Token de registro definido como nulo.");

        return Error(
          ExpiredLoginException(
            "Login expirado. Faça login novamente para continuar.",
          ),
        );
      }

      // Attempt registration
      final result = await _authRepository.register(
        nome: requestModel.nome,
        cpf: requestModel.cpf,
        dataNascimento: requestModel.dataNascimento,
        telefone: requestModel.telefone,
        registerToken: registerToken,
      );

      if (result.isError()) {
        _log.severe("Registration failed: ", result.tryGetError()!);
        return Error(
          UnexpectedRegisterException(
            "Ocorreu um erro desconhecido durante o processo de registro",
          ),
        );
      }

      final sessionToken = result.getOrThrow();

      // Clear register token since registration is complete
      _sessionRepository.clearRegisterToken();

      // Store session token
      final storeResult = await _sessionRepository.setAuthToken(sessionToken);

      if (storeResult.isError()) {
        _log.severe(
          "Failed to store session token: ",
          storeResult.tryGetError()!,
        );
        return Error(
          UnexpectedRegisterException(
            "Ocorreu um erro desconhecido durante o processo de registro",
          ),
        );
      }

      return Success(null);
    } catch (e) {
      _log.severe("Unexpected error: ", e);
      return Error(
        UnexpectedRegisterException(
          "Ocorreu um erro desconhecido durante o processo de registro",
        ),
      );
    }
  }
}

class RegisterRequestModel {
  String nome;
  String cpf;
  DateTime dataNascimento;
  String telefone;

  RegisterRequestModel({
    required this.nome,
    required this.cpf,
    required this.dataNascimento,
    required this.telefone,
  }) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    telefone = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    dataNascimento = DateTime(
      dataNascimento.year,
      dataNascimento.month,
      dataNascimento.day,
    );
    nome = nome.substring(0, nome.length.clamp(0, 100)).trim();
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
