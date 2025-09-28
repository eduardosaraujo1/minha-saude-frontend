import 'package:minha_saude_frontend/app/data/services/api/models/login_response/login_response.dart';
import 'package:minha_saude_frontend/app/domain/models/user_register_model/user_register_model.dart';
import 'package:multiple_result/src/result.dart';

import 'auth_repository.dart';

class AuthRepositoryLocal implements AuthRepository {
  // [AUTHENTICATION]
  @override
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String googleServerCode,
  ) {
    // TODO: implement loginWithGoogle
    throw UnimplementedError();
  }

  @override
  Future<Result<LoginResponse, Exception>> loginWithEmail(
    String email,
    String code,
  ) {
    // TODO: implement loginWithEmail
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> requestEmailCode(String email) {
    // TODO: implement requestEmailCode
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> register(UserRegisterModel registerModel) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Result<String?, Exception> getRegisterToken() {
    // TODO: implement getRegisterToken
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  // [GOOGLE INTEGRATION]
  @override
  Future<Result<String?, Exception>> getGoogleServerToken() {
    // TODO: implement getGoogleServerToken
    throw UnimplementedError();
  }

  // [TOKEN]
  @override
  Future<Result<String?, Exception>> getAuthToken() {
    // TODO: implement getAuthToken
    throw UnimplementedError();
  }

  @override
  Future<bool> hasToken() async {
    final result = await getAuthToken();

    return result.tryGetSuccess() != null;
  }
}
