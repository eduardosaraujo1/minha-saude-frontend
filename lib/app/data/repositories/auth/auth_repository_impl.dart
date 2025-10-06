import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/services/api/auth/auth_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/api/auth/models/login_response/login_api_response.dart';
import 'package:minha_saude_frontend/app/data/services/google/google_service.dart';
import 'package:minha_saude_frontend/app/data/services/secure_storage/secure_storage.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/user_register_model/user_register_model.dart';
import 'package:multiple_result/multiple_result.dart';

import 'auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  AuthRepositoryImpl(this._secureStorage, this._googleService, this._apiClient);

  final SecureStorage _secureStorage;
  final GoogleService _googleService;
  final AuthApiClient _apiClient;
  final Logger _log = Logger("AuthRepositoryImplementation");

  String? _registerToken;
  String? _authTokenCache;

  Result<LoginResult, Exception> _parseApiLoginResponse(
    LoginApiResponse response,
  ) {
    try {
      final loginResponse = LoginResult.fromApi(response);
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
    } else {
      return Result.error(Exception("Não foi possível autenticar o usuário."));
    }

    return Result.success(_authTokenCache);
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
        Exception('Não foi possível autenticar-se com o Google'),
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
  Future<Result<LoginResult, Exception>> loginWithEmail(
    String email,
    String code,
  ) async {
    try {
      final result = await _apiClient.authLoginEmail(email, code);

      if (result.isError()) {
        _log.severe("Login E-mail tentativa falhou: ", result.tryGetError()!);
        return Result.error(
          Exception("Ocorreu um erro desconhecido ao fazer login."),
        );
      }

      final apiLoginResponse = result.tryGetSuccess()!;
      final loginResponseResult = _parseApiLoginResponse(apiLoginResponse);

      if (loginResponseResult.isError()) {
        return Result.error(Exception("Ocorreu um erro ao fazer login."));
      }

      return Result.success(loginResponseResult.tryGetSuccess()!);
    } on Exception catch (e) {
      _log.warning("Unexpected error", e);
      return Result.error(Exception("Ocorreu um erro inesperado."));
    }
  }

  @override
  Future<Result<LoginResult, Exception>> loginWithGoogle(
    String googleServerCode,
  ) async {
    try {
      final result = await _apiClient.authLoginGoogle(googleServerCode);

      if (result.isError()) {
        _log.severe("Login Google tentativa falhou: ", result.tryGetError()!);
        return Result.error(
          Exception("Ocorreu um erro desconhecido ao fazer login."),
        );
      }

      final apiLoginResponse = result.tryGetSuccess()!;
      final loginResponseResult = _parseApiLoginResponse(apiLoginResponse);

      if (loginResponseResult.isError()) {
        return Result.error(Exception("Ocorreu um erro ao fazer login."));
      }

      return Result.success(loginResponseResult.tryGetSuccess()!);
    } on Exception catch (e) {
      _log.warning("Unexpected error", e);
      return Result.error(Exception("Ocorreu um erro inesperado."));
    }
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

    // Reset CacheDatabase
    // TODO: implement this
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
      // Limpar secureStorage
      final clearResult = await _secureStorage.clearAuthToken();

      if (clearResult.isError()) {
        return Result.error(
          Exception(
            "Ocorreu um erro inesperado ao tentar remover o token de autenticação",
          ),
        );
      }

      // Limpar cache
      _authTokenCache = null;

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
