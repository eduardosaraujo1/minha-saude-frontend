import 'package:command_it/command_it.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../view_model.dart';
import '../../../domain/actions/auth/login_with_google.dart';

class LoginViewModel implements ViewModel {
  LoginViewModel(this._loginWithGoogleAction) {
    loginWithGoogle = Command.createAsyncNoParam(
      _loginWithGoogle,
      initialValue: null,
    );
  }

  final LoginWithGoogle _loginWithGoogleAction;
  final _log = Logger("LoginViewModel");

  /// Command to initiate Google login, returns an app route path to redirect to
  /// Rebuild Widget when this notifies
  /// If result is error then display Snackbar and clear result
  /// If result is success, then use context.go to redirect
  late Command<void, Result<RedirectResponse, Exception>?> loginWithGoogle;

  /// Perform login with Google action
  /// Returns a nullable string that is the route to redirect to
  Future<Result<RedirectResponse, Exception>> _loginWithGoogle() async {
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

      return Success(redirectResult.getOrThrow());
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

enum LoginStatus { initial, loading, error, authenticated, needsRegistration }
