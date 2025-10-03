import 'package:multiple_result/multiple_result.dart';

import '../../../../domain/models/user_register_model/user_register_model.dart';
import 'models/login_response/login_api_response.dart';
import 'models/register_response/register_response.dart';
import 'auth_api_client.dart';

class FakeAuthApiClient implements AuthApiClient {
  bool _isRegistered = false;

  @override
  set authHeaderProvider(AuthHeaderProvider provider) {
    return;
  }

  @override
  Future<Result<LoginApiResponse, Exception>> authLoginGoogle(
    String tokenOauth,
  ) async {
    if (_isRegistered) {
      return Result.success(
        LoginApiResponse(
          isRegistered: true,
          sessionToken: 'fake_session_token',
          registerToken: null,
        ),
      );
    } else {
      return Result.success(
        LoginApiResponse(
          isRegistered: false,
          sessionToken: null,
          registerToken: 'fake_register_token',
        ),
      );
    }
  }

  @override
  Future<Result<RegisterResponse, Exception>> authRegister(
    UserRegisterModel data,
  ) async {
    _isRegistered = true;

    return Result.success(
      RegisterResponse(status: 'success', sessionToken: 'fake_session_token'),
    );
  }

  @override
  Future<Result<void, Exception>> authLogout() async {
    return Result.success(null);
  }

  @override
  Future<Result<String, Exception>> authSendEmail(String email) async {
    return Result.success("success");
  }

  @override
  Future<Result<LoginApiResponse, Exception>> authLoginEmail(
    String email,
    String code,
  ) async {
    if (_isRegistered) {
      return Result.success(
        LoginApiResponse(
          isRegistered: true,
          sessionToken: 'fake_session_token',
          registerToken: null,
        ),
      );
    } else {
      return Result.success(
        LoginApiResponse(
          isRegistered: false,
          sessionToken: null,
          registerToken: 'fake_register_token',
        ),
      );
    }
  }
}
