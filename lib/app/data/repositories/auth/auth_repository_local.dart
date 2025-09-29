import 'package:minha_saude_frontend/app/data/services/api/api_client.dart';
import 'package:minha_saude_frontend/app/data/services/api/models/login_response/login_response.dart';
import 'package:minha_saude_frontend/app/data/services/google/google_service.dart';
import 'package:minha_saude_frontend/app/data/services/secure_storage.dart';
import 'package:minha_saude_frontend/app/domain/models/user_register_model/user_register_model.dart';
import 'package:multiple_result/multiple_result.dart';

import 'auth_repository.dart';

class AuthRepositoryLocal implements AuthRepository {
  AuthRepositoryLocal(
    this._secureStorage,
    this._googleService,
    this._apiClient,
  );

  final SecureStorage _secureStorage;
  final GoogleService _googleService;
  final ApiClient _apiClient;

  String? _registerToken;
  String? _authTokenCache;

  @override
  Future<Result<String?, Exception>> getAuthToken() async {
    // Return cached token if available
    if (_authTokenCache != null) {
      return Result.success(_authTokenCache);
    }

    // Try to get token from secure storage
    final result = await _secureStorage.getAuthToken();
    if (result.isSuccess()) {
      _authTokenCache = result.tryGetSuccess();
    }
    return result;
  }

  @override
  Future<Result<String, Exception>> getGoogleServerToken() async {
    final result = await _googleService.generateServerAuthCode();
    if (result.isError()) {
      return Result.error(result.tryGetError()!);
    }

    final serverCode = result.tryGetSuccess();
    if (serverCode == null || serverCode.isEmpty) {
      return Result.error(
        Exception('Google server auth code is null or empty'),
      );
    }

    return Result.success(serverCode);
  }

  @override
  String? getRegisterToken() {
    return _registerToken;
  }

  @override
  Future<bool> hasAuthToken() async {
    final tokenResult = await getAuthToken();
    return tokenResult.isSuccess() && tokenResult.tryGetSuccess() != null;
  }

  @override
  bool hasRegisterToken() {
    return _registerToken != null;
  }

  @override
  Future<Result<LoginResponse, Exception>> loginWithEmail(
    String email,
    String code,
  ) async {
    final result = await _apiClient.authLoginEmail(email, code);

    if (result.isError()) {
      return result;
    }

    final loginResponse = result.tryGetSuccess()!;

    // Handle login response based on registration status
    if (loginResponse.isRegistered) {
      // User is registered, store session token
      if (loginResponse.sessionToken != null) {
        await setAuthToken(loginResponse.sessionToken);
      }
    } else {
      // User needs to register, store register token
      if (loginResponse.registerToken != null) {
        setRegisterToken(loginResponse.registerToken);
      }
    }

    return result;
  }

  @override
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String googleServerCode,
  ) async {
    final result = await _apiClient.authLoginGoogle(googleServerCode);

    if (result.isError()) {
      return result;
    }

    final loginResponse = result.tryGetSuccess()!;

    // Handle login response based on registration status
    if (loginResponse.isRegistered) {
      // User is registered, store session token
      if (loginResponse.sessionToken != null) {
        await setAuthToken(loginResponse.sessionToken);
      }
    } else {
      // User needs to register, store register token
      if (loginResponse.registerToken != null) {
        setRegisterToken(loginResponse.registerToken);
      }
    }

    return result;
  }

  @override
  Future<void> logout() async {
    // Call API logout if we have a token
    if (_authTokenCache != null) {
      await _apiClient.authLogout();
    }

    // Clear all local auth state
    await setAuthToken(null);
    setRegisterToken(null);
  }

  @override
  Future<Result<void, Exception>> register(
    UserRegisterModel registerModel,
  ) async {
    final result = await _apiClient.authRegister(registerModel);

    if (result.isError()) {
      return Result.error(result.tryGetError()!);
    }

    final registerResponse = result.tryGetSuccess()!;

    // Clear register token since registration is complete
    setRegisterToken(null);

    // Store session token
    if (registerResponse.sessionToken != null) {
      await setAuthToken(registerResponse.sessionToken);
    }

    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> requestEmailCode(String email) async {
    final result = await _apiClient.authSendEmail(email);

    if (result.isError()) {
      return Result.error(result.tryGetError()!);
    }

    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> setAuthToken(String? value) async {
    _authTokenCache = value;
    return await _secureStorage.setAuthToken(value);
  }

  @override
  bool setRegisterToken(String? value) {
    _registerToken = value;
    return true;
  }
}
