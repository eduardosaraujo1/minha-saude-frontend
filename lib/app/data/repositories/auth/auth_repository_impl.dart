import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../services/api/auth/auth_api_client.dart';
import '../../services/api/auth/models/login_response/login_api_response.dart';
import '../../services/google/google_service.dart';
import '../../../domain/models/auth/login_response/login_result.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  AuthRepositoryImpl({
    required GoogleService googleService,
    required AuthApiClient apiClient,
  }) : _googleService = googleService,
       _apiClient = apiClient;

  final GoogleService _googleService;
  final AuthApiClient _apiClient;
  final Logger _log = Logger("AuthRepositoryImplementation");

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
    await _apiClient.authLogout();
  }

  @override
  Future<Result<String, Exception>> register({
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String telefone,
    required String registerToken,
  }) async {
    final result = await _apiClient.authRegister(
      nome: nome,
      cpf: cpf,
      dataNascimento: dataNascimento,
      telefone: telefone,
      registerToken: registerToken,
    );

    if (result.isError()) {
      return Result.error(result.tryGetError()!);
    }

    final registerResponse = result.tryGetSuccess()!;

    if (registerResponse.sessionToken == null ||
        registerResponse.sessionToken!.isEmpty) {
      return Result.error(
        Exception("Ocorreu um erro desconhecido ao tentar registrar."),
      );
    }

    return Result.success(registerResponse.sessionToken!);
  }

  @override
  Future<Result<void, Exception>> requestEmailCode(String email) async {
    final result = await _apiClient.authSendEmail(email);

    if (result.isError()) {
      return Result.error(result.tryGetError()!);
    }

    return Result.success(null);
  }
}
