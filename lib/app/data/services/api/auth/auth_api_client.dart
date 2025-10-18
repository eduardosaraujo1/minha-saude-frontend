import 'package:multiple_result/multiple_result.dart';

import 'models/login_response/login_api_response.dart';
import 'models/register_response/register_response.dart';

abstract class AuthApiClient {
  /// Login with Google server code
  Future<Result<LoginApiResponse, Exception>> authLoginGoogle(
    String tokenOauth,
  );

  /// Login with email and one time code
  Future<Result<LoginApiResponse, ApiEmailLoginException>> authLoginEmail(
    String email,
    String code,
  );

  /// Send one time code to email
  Future<Result<void, Exception>> authSendEmail(String email);

  /// Register new user
  Future<Result<RegisterResponse, Exception>> authRegister({
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String telefone,
    required String registerToken,
  });

  /// Signout
  Future<Result<void, Exception>> authLogout();
}

sealed class ApiEmailLoginException implements Exception {
  final String message;

  const ApiEmailLoginException(this.message);
}

class ApiEmailLoginIncorrectCodeException extends ApiEmailLoginException {
  const ApiEmailLoginIncorrectCodeException(super.message);
}

class ApiUnexpectedEmailLoginException extends ApiEmailLoginException {
  const ApiUnexpectedEmailLoginException(super.message);
}
