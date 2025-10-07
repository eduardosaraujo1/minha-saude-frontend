import 'package:minha_saude_frontend/app/data/repositories/session/session_repository.dart';
import 'package:minha_saude_frontend/app/data/services/secure_storage/secure_storage.dart';
import 'package:multiple_result/multiple_result.dart';

class SessionRepositoryImpl extends SessionRepository {
  String? _registerToken;
  String? _authTokenCache;

  final SecureStorage _secureStorage;

  SessionRepositoryImpl({required SecureStorage secureStorage})
    : _secureStorage = secureStorage;

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
  void clearRegisterToken() {
    _registerToken = null;
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
  Future<void> logout() async {
    await clearAuthToken();
    setRegisterToken(null);
  }
}
