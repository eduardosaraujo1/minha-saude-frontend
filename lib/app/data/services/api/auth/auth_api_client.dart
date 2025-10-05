import 'package:multiple_result/multiple_result.dart';

import 'models/login_response/login_api_response.dart';
import 'models/register_response/register_response.dart';
import '../../../../domain/models/auth/user_register_model/user_register_model.dart';

abstract class AuthApiClient {
  /// Login with Google server code
  Future<Result<LoginApiResponse, Exception>> authLoginGoogle(
    String tokenOauth,
  );

  /// Login with email and one time code
  Future<Result<LoginApiResponse, Exception>> authLoginEmail(
    String email,
    String code,
  );

  /// Send one time code to email
  Future<Result<String, Exception>> authSendEmail(String email);

  /// Register new user
  Future<Result<RegisterResponse, Exception>> authRegister(
    UserRegisterModel data,
  );

  /// Signout
  Future<Result<void, Exception>> authLogout();
}
