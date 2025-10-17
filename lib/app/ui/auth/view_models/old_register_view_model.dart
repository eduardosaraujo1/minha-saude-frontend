import 'package:command_it/command_it.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../view_model.dart';
import '../../../domain/actions/auth/register_action.dart';

class OldRegisterViewModel implements ViewModel {
  OldRegisterViewModel({required this.registerAction}) {
    registerCommand = Command.createAsync(_registerUser, initialValue: null);
  }

  final RegisterAction registerAction;
  final Logger _log = Logger("RegisterViewModel");

  /// Registers used with provided request
  ///
  /// Returns [Success] on success
  /// Returns [Error] with [ExpiredLoginException] on failure due to expired login
  /// Returns [Error] with [Exception] on other failures
  late Command<RegisterRequestModel, Result<void, Exception>?> registerCommand;

  /// Register user with provided form data
  Future<Result<void, Exception>?> _registerUser(
    RegisterRequestModel requestModel,
  ) async {
    try {
      // Iniciar registro
      final result = await registerAction.execute(
        nome: requestModel.nome,
        cpf: requestModel.cpf,
        dataNascimento: requestModel.dataNascimento,
        telefone: requestModel.telefone,
      );

      if (result.isError()) {
        if (result.tryGetError()! is ExpiredLoginException) {
          return Error(result.tryGetError()!);
        }

        return Error(Exception("Falha ao registrar usuário"));
      }

      return Success(null);
    } catch (e) {
      _log.severe("Ocorreu um erro desconhecido durante o registro: $e");
      return Result.error(
        Exception("Ocorreu um erro desconhecido durante o registro."),
      );
    }
  }

  /// Dispose form controllers
  @override
  void dispose() {
    registerCommand.dispose();
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
  });
}
