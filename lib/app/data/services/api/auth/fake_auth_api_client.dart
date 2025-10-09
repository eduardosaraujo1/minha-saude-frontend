import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../domain/models/auth/user_register_model/user_register_model.dart';
import 'models/login_response/login_api_response.dart';
import 'models/register_response/register_response.dart';
import 'auth_api_client.dart';

class FakeAuthApiClient implements AuthApiClient {
  FakeAuthApiClient();

  final _FakeAuthPersistentStorage _store = _FakeAuthPersistentStorage();

  @override
  Future<Result<LoginApiResponse, Exception>> authLoginGoogle(
    String tokenOauth,
  ) async {
    if (!await _store.getRegistered()) {
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
    await _store.setRegistered(true);

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
    if (await _store.getRegistered()) {
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
          registerToken: 'fake_register_token',
        ),
      );
    }
  }
}

class _FakeAuthPersistentStorage {
  _FakeAuthPersistentStorage() {
    _init();
  }

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  bool? _isRegistered;

  Future<void> setRegistered(bool value) async {
    _isRegistered = value;

    // Update SecureStorage
    _secureStorage.write(key: 'is_registered', value: value ? 'true' : 'false');
  }

  Future<bool> getRegistered({bool forceRefresh = false}) async {
    if (forceRefresh || _isRegistered == null) {
      await _init();
    }
    return _isRegistered ?? false;
  }

  Future<void> _init() async {
    final val = await _secureStorage.read(key: 'is_registered');
    _isRegistered = (val == 'true');
  }
}
