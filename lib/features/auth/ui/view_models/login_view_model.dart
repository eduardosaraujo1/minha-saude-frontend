import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:minha_saude_frontend/features/auth/data/models/auth_response.dart';
import 'package:minha_saude_frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:multiple_result/multiple_result.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository) {
    loginCommand = Command.createAsyncNoParam(() async {
      // Perform login logic here
      Result<LoginResponse, Exception> result = await _authRepository
          .loginWithGoogle();

      if (result.isError()) {
        _errorMessage = result.tryGetError()!.toString();
        return LoginStatus.error;
      }

      final signInResult = result.tryGetSuccess()!;

      if (signInResult.needsRegistration) {
        return LoginStatus.needsRegistration;
      }

      if (signInResult.sessionToken != null) {
        // Add session token to Session class
        return LoginStatus.authenticated;
      } else {
        _errorMessage = "Unknown login result";
        return LoginStatus.error;
      }
    }, initialValue: LoginStatus.initial);
  }

  late Command<void, LoginStatus> loginCommand;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;
}

enum LoginStatus { initial, authenticated, needsRegistration, error }
