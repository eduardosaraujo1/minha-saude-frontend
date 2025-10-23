import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/auth/login_response/login_result.dart';
import '../../services/api/gateway/api_gateway.dart';
import '../../services/api/deprecating/auth/models/login_response/login_api_response.dart';
import '../../services/api/deprecating/auth/models/register_response/register_response.dart';
import '../../services/api/gateway/routes.dart';
import '../../services/google/google_service.dart';

part 'local_auth_repository.dart';
// part 'remote_auth_repository.dart';

abstract class AuthRepository extends ChangeNotifier {
  // [AUTHENTICATION]
  /// Login with Google exchanging server code for auth token
  Future<Result<LoginResult, Exception>> loginWithGoogle(
    String googleServerCode,
  );

  /// Login with email and code
  Future<Result<LoginResult, EmailLoginException>> loginWithEmail(
    String email,
    String code,
  );

  /// Get e-mail code for login
  Future<Result<void, Exception>> requestEmailCode(String email);

  /// Register a new user through token from login attempt
  ///
  /// Returns [String] which is the auth session token if registration succeeds
  Future<Result<String, Exception>> register({
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String telefone,
    required String registerToken,
  });

  /// Sign out the current user, both through server and clearing local data
  /// Clears the CacheDatabase as well as the auth token stored in SecureStorage
  Future<void> logout();

  // [GOOGLE INTEGRATION]
  /// Gets the current auth token, reading from SecureStorage if unavailable in memory
  Future<Result<String, Exception>> getGoogleServerToken();
}

sealed class EmailLoginException implements Exception {
  final String message;

  const EmailLoginException(this.message);
}

class EmailLoginIncorrectCodeException extends EmailLoginException {
  const EmailLoginIncorrectCodeException(super.message);
}

class EmailLoginUnexpectedException extends EmailLoginException {
  const EmailLoginUnexpectedException(super.message);
}
