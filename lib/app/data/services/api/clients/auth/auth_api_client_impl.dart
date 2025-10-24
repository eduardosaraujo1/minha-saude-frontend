import 'package:multiple_result/multiple_result.dart';

import 'auth_api_client.dart';
import 'models/login_response/login_api_response.dart';
import 'models/register_response/register_response.dart';

class AuthApiClientImpl implements AuthApiClient {
  @override
  Future<Result<LoginApiResponse, ApiEmailLoginException>> authLoginEmail(
    String email,
    String code,
  ) {
    // TODO: implement authLoginEmail
    throw UnimplementedError();
  }

  @override
  Future<Result<LoginApiResponse, Exception>> authLoginGoogle(
    String tokenOauth,
  ) {
    // TODO: implement authLoginGoogle
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> authLogout() {
    // TODO: implement authLogout
    throw UnimplementedError();
  }

  @override
  Future<Result<RegisterResponse, Exception>> authRegister({
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String telefone,
    required String registerToken,
  }) {
    // TODO: implement authRegister
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> authSendEmail(String email) {
    // TODO: implement authSendEmail
    throw UnimplementedError();
  }
}
