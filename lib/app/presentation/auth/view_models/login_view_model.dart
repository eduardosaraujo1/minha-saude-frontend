import 'package:command_it/command_it.dart';
import 'package:minha_saude_frontend/app/data/auth/DTO/login_response.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/container/get_it.dart';
import 'package:multiple_result/multiple_result.dart';

class LoginViewModel {
  final AuthRepository _authRepository = getIt<AuthRepository>();

  late Command<void, LoginCommandResponse> loginWithGoogleCommand;

  LoginViewModel() {
    loginWithGoogleCommand = Command.createAsyncNoParam(() async {
      try {
        // Perform login logic here
        Result<LoginResponse, Exception> result = await _authRepository
            .loginWithGoogle();

        if (result.isError()) {
          return LoginCommandResponse.error(result.tryGetError()!.toString());
        }

        final signInResult = result.getOrThrow();

        if (signInResult.needsRegistration) {
          return LoginCommandResponse.success(LoginStatus.needsRegistration);
        }

        // TODO: check the AuthRepository to verify the token is actually cached
        if (signInResult.sessionToken != null) {
          return LoginCommandResponse.success(LoginStatus.authenticated);
        } else {
          return LoginCommandResponse.error("Ocorreu um erro desconhecido.");
        }
      } catch (e) {
        // Handle any unexpected errors
        return LoginCommandResponse.error("Ocorreu um erro desconhecido.");
      }
    }, initialValue: LoginCommandResponse.success(LoginStatus.initial));
  }
}

/// Response object for login command operations
class LoginCommandResponse {
  final LoginStatus status;
  final String? errorMessage;

  const LoginCommandResponse({required this.status, this.errorMessage});

  /// Factory constructor for successful responses
  factory LoginCommandResponse.success(LoginStatus status) {
    return LoginCommandResponse(status: status);
  }

  /// Factory constructor for error responses
  factory LoginCommandResponse.error(String message) {
    return LoginCommandResponse(
      status: LoginStatus.error,
      errorMessage: message,
    );
  }

  bool get isError => status == LoginStatus.error;
  bool get isSuccess => !isError;
}

enum LoginStatus { initial, authenticated, needsRegistration, error }
