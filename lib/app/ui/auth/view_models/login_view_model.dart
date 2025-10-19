import 'package:command_it/command_it.dart';
import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/process_login_result_action.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/auth/login_response/login_result.dart';
import '../../view_model.dart';

class LoginViewModel implements ViewModel {
  LoginViewModel({
    required AuthRepository authRepository,
    required ProcessLoginResultAction processLoginAction,
  }) : _authRepository = authRepository,
       _processGoogleLoginAction = processLoginAction {
    loginWithGoogle = Command.createAsyncNoParam(
      _loginWithGoogle,
      initialValue: null,
    );
  }

  final ProcessLoginResultAction _processGoogleLoginAction;
  final AuthRepository _authRepository;
  final _log = Logger("LoginViewModel");

  /// Command to initiate Google login, returns an app route path to redirect to
  /// Rebuild Widget when this notifies
  /// If result is error then display Snackbar and clear result
  /// If result is success, then use context.go to redirect
  late Command<void, Result<LoginResult, Exception>?> loginWithGoogle;

  /// Perform login with Google action
  /// Returns a nullable string that is the route to redirect to
  Future<Result<LoginResult, Exception>> _loginWithGoogle() async {
    try {
      final Exception defaultErr = Exception(
        "Não foi possível fazer login com o Google.",
      );

      // Get Google server auth token
      final googleTokenResult = await _authRepository.getGoogleServerToken();
      if (googleTokenResult.isError()) {
        _log.severe(
          "Failed to get Google server token",
          googleTokenResult.tryGetError(),
        );
        return Error(defaultErr);
      }

      // Use googleToken to login with google
      final loginResult = await _authRepository.loginWithGoogle(
        googleTokenResult.tryGetSuccess()!,
      );
      if (loginResult.isError()) {
        _log.severe("Login with Google failed: ${loginResult.tryGetError()}");
        return Error(Exception(defaultErr));
      }

      // Store token based on login response type
      final storeResult = await _processGoogleLoginAction.execute(
        loginResult.tryGetSuccess()!,
      );

      if (storeResult.isError()) {
        _log.severe("Login was successful, but couldn't store token");
        return Error(
          Exception("Não foi possível salvar o token de autenticação."),
        );
      }

      return loginResult;
    } catch (e) {
      _log.severe("Ocorreu um erro desconhecido:", e);
      return Result.error(
        Exception("Ocorreu um erro desconhecido. Por favor, tente novamente."),
      );
    }
  }

  @override
  void dispose() {
    loginWithGoogle.dispose();
  }
}
