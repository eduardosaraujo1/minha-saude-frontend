import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/services/api/api_client.dart';
import 'package:minha_saude_frontend/app/data/services/api/models/login_response/login_api_response.dart';
import 'package:minha_saude_frontend/app/data/services/google/google_service.dart';
import 'package:minha_saude_frontend/app/data/services/secure_storage/secure_storage.dart';
import 'package:minha_saude_frontend/app/domain/models/login_response/login_response.dart';
import 'package:minha_saude_frontend/app/domain/models/user_register_model/user_register_model.dart';
import 'package:multiple_result/multiple_result.dart';

import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._secureStorage, this._googleService, this._apiClient);

  final SecureStorage _secureStorage;
  final GoogleService _googleService;
  final ApiClient _apiClient;
  final Logger _log = Logger("AuthRepositoryImplementation");

  String? _registerToken;
  String? _authTokenCache;

  Result<LoginResponse, Exception> _parseApiLoginResponse(
    LoginApiResponse response,
  ) {
    try {
      final loginResponse = LoginResponse.fromApi(response);
      return Result.success(loginResponse);
    } on Exception catch (e) {
      _log.warning("Invalid API Login Response: $response", e);
      return Result.error(
        Exception("Não foi possível determinar situação de login"),
      );
    }
  }

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

  Future<Result<LoginResponse, Exception>> _login(
    Future<Result<LoginApiResponse, Exception>> Function() apiCall,
    String loginType,
  ) async {
    try {
      final result = await apiCall();

      if (result.isError()) {
        _log.severe(
          "Login $loginType tentativa falhou: ",
          result.tryGetError()!,
        );
        return Result.error(
          Exception("Ocorreu um erro desconhecido ao fazer login."),
        );
      }

      final apiLoginResponse = result.tryGetSuccess()!;

      // Parse API login response into valid domain object
      final loginResponseResult = _parseApiLoginResponse(apiLoginResponse);

      if (loginResponseResult.isError()) {
        return Result.error(Exception("Ocorreu um erro ao fazer login."));
      }

      final loginResponse = loginResponseResult.tryGetSuccess()!;

      // Handle login response based on registration status
      if (loginResponse is SuccessfulLoginResponse) {
        await setAuthToken(apiLoginResponse.sessionToken!);
      } else if (loginResponse is NeedsRegistrationLoginResponse) {
        setRegisterToken(loginResponse.registerToken);
      } else {
        _log.warning("Invalid state of LoginResponse: $loginResponse");
        return Result.error(Exception("Ocorreu um erro desconhecido."));
      }

      return Result.success(loginResponse);
    } on Exception catch (e) {
      _log.warning("Unexpected error", e);
      return Result.error(Exception("Ocorreu um erro inesperado."));
    }
  }

  @override
  Future<Result<LoginResponse, Exception>> loginWithEmail(
    String email,
    String code,
  ) async {
    return _login(() => _apiClient.authLoginEmail(email, code), "E-mail");
  }

  @override
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String googleServerCode,
  ) async {
    return _login(() => _apiClient.authLoginGoogle(googleServerCode), "Google");
  }

  @override
  Future<void> logout() async {
    // Call API logout if we have a token
    if (_authTokenCache != null) {
      await _apiClient.authLogout();
    }

    // Clear all local auth state
    await clearAuthToken();
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
      await setAuthToken(registerResponse.sessionToken!);
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
  Future<Result<void, Exception>> setAuthToken(String value) async {
    _authTokenCache = value;
    return await _secureStorage.setAuthToken(value);
  }

  @override
  bool setRegisterToken(String? value) {
    _registerToken = value;
    return true;
  }

  @override
  Future<Result<void, Exception>> clearAuthToken() async {
    try {
      final clearResult = await _secureStorage.clearAuthToken();

      if (clearResult.isError()) {
        return Result.error(
          Exception(
            "Ocorreu um erro inesperado ao tentar remover o token de autenticação",
          ),
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(
        Exception(
          "Ocorreu um eror crítico ao tentar remover o token de autenticação",
        ),
      );
    }
  }

  @override
  void clearRegisterToken(String? value) {
    _registerToken = null;
  }
}
