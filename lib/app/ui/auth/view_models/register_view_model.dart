// Control navigation, terms of service and form submission here

import 'package:command_it/command_it.dart';
import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/get_tos_action.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/actions/auth/register_action.dart';
import '../../view_model.dart';

class RegisterViewModel implements ViewModel {
  RegisterViewModel({
    required RegisterAction registerAction,
    required GetTosAction getTosAction,
  }) : _getTosAction = getTosAction,
       _registerAction = registerAction {
    loadTosCommand = Command.createAsyncNoParam(_loadTos, initialValue: null);
    registerCommand = Command.createAsync(_registerUser, initialValue: null);
  }

  final RegisterAction _registerAction;
  final GetTosAction _getTosAction;

  final Logger _logger = Logger('RegisterViewModel');

  /// Loads Terms of Service from assets
  ///
  /// Returns [Success] with Terms of Service text on success
  /// Returns [Error] with [Exception] on failure
  late final Command<void, Result<String, Exception>?> loadTosCommand;

  /// Registers used with provided request
  ///
  /// Returns [Success] on success
  /// Returns [Error] on failure with the following cases:
  /// - [ExpiredLoginException] on failure due to expired login
  /// - [UnexpectedRegisterException] on other failures
  late Command<RegisterRequestModel, Result<void, RegisterException>?>
  registerCommand;

  @override
  void dispose() {
    loadTosCommand.dispose();
  }

  Future<Result<String, Exception>> _loadTos() async {
    try {
      // Delegate to action
      return await _getTosAction.execute();
    } catch (e, s) {
      _logger.severe('Failed to load Terms of Service: $e', e, s);
      return Error(
        Exception(
          'Não foi possível carregar os Termos de Serviço. Consulte nossa equipe de suporte.',
        ),
      );
    }
  }

  /// Register user with provided form data
  Future<Result<void, RegisterException>?> _registerUser(
    RegisterRequestModel requestModel,
  ) async {
    try {
      // Delegate to action
      return await _registerAction.execute(requestModel);
    } catch (e, s) {
      _logger.severe("Ocorreu um erro desconhecido durante o registro", e, s);
      return Result.error(
        UnexpectedRegisterException(
          "Ocorreu um erro desconhecido durante o registro.",
        ),
      );
    }
  }
}
