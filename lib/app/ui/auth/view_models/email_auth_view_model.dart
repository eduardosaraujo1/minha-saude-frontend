import 'package:command_it/command_it.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../domain/models/auth/login_response/login_result.dart';
import '../../view_model.dart';

class EmailAuthViewModel implements ViewModel {
  EmailAuthViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    requestCodeCommand = Command.createAsync(_requestCode, initialValue: null);
    verifyCodeCommand = Command.createAsync(_verifyCode, initialValue: null);
  }

  final AuthRepository _authRepository;
  final Logger _logger = Logger('EmailAuthViewModel');

  /// Requests a verification code to be sent to the provided e-mail address.
  ///
  /// Returns the e-mail the code was sent to on success to be used for confirmation.
  ///
  /// Returns an [Exception] on failure
  late final Command<String, Result<String, Exception>?> requestCodeCommand;

  /// Confirms the provided code to be the same as the one sent by the server.
  ///
  /// Authenticates the user if the code is correct.
  ///
  /// Returns [Success] with [LoginResult] value when successful, which can be one of:
  /// - [SuccessfulLoginResult]: The user has successfully logged in.
  /// - [NeedsRegistrationLoginResult]: The user needs to complete registration.
  ///
  /// Returns an [CodeVerificationException] on failure, which can be one of:
  /// - [IncorrectCodeException]: The provided code was incorrect.
  /// - [UnexpectedVerificationException]: A general exception occurred during verification.
  late final Command<String, Result<LoginResult, CodeVerificationException>?>
  verifyCodeCommand;

  Future<Result<String, Exception>> _requestCode(String email) async {
    try {
      // TODO: Implement email sending logic here.
      throw UnimplementedError();
    } catch (e) {
      return Error(Exception("Failed to send verification code."));
    }
  }

  Future<Result<LoginResult, CodeVerificationException>> _verifyCode(
    String code,
  ) async {
    try {
      // TODO: Implement email verification logic here
      throw UnimplementedError();
    } catch (e) {
      return Error(IncorrectCodeException("Failed to verify code."));
    }
  }

  @override
  void dispose() {
    requestCodeCommand.dispose();
    verifyCodeCommand.dispose();
  }
}

abstract class CodeVerificationException implements Exception {
  final String message;

  CodeVerificationException(this.message);
}

class UnexpectedVerificationException extends CodeVerificationException {
  UnexpectedVerificationException(super.message);
}

class IncorrectCodeException extends CodeVerificationException {
  IncorrectCodeException(super.message);
}
