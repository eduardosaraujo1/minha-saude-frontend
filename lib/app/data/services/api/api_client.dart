import 'package:multiple_result/multiple_result.dart';

import '../../../../app/data/services/api/models/login_response/login_api_response.dart';
import '../../../../app/data/services/api/models/register_response/register_response.dart';
import '../../../../app/domain/models/user_register_model/user_register_model.dart';
export 'api_client_impl.dart';
export 'fake_api_client.dart';

typedef AuthHeaderProvider = Future<String?> Function();

abstract class ApiClient {
  set authHeaderProvider(AuthHeaderProvider provider);

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
