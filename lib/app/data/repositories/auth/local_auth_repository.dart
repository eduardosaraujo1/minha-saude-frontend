part of 'auth_repository.dart';

class LocalAuthRepository extends AuthRepository {
  LocalAuthRepository({
    required GoogleService googleService,
    required ApiGateway apiGateway,
  }) : _googleService = googleService,
       _apiGateway = apiGateway;

  final GoogleService _googleService;
  final ApiGateway _apiGateway;
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
  Future<Result<LoginResult, EmailLoginException>> loginWithEmail(
    String email,
    String code,
  ) async {
    try {
      final result = await _apiGateway.post(
        GatewayRoutes.loginEmail,
        data: {'email': email, 'codigoEmail': code},
      );

      if (result.isError()) {
        _log.severe("Login E-mail tentativa falhou: ", result.tryGetError()!);
        final error = result.tryGetError()!;

        // Check if it's a client error that might be incorrect code
        if (error is ClientException && error.message.contains('400')) {
          return Error(
            EmailLoginIncorrectCodeException(
              "Código de verificação incorreto.",
            ),
          );
        }

        return Error(
          EmailLoginUnexpectedException("Erro ao fazer login por e-mail."),
        );
      }

      final responseData = result.tryGetSuccess()!;
      final apiLoginResponse = LoginApiResponse.fromJson(responseData);
      final loginResponseResult = _parseApiLoginResponse(apiLoginResponse);

      if (loginResponseResult.isError()) {
        return Error(
          EmailLoginUnexpectedException("Ocorreu um erro ao fazer login."),
        );
      }

      return Result.success(loginResponseResult.tryGetSuccess()!);
    } on Exception catch (e) {
      _log.warning("Unexpected error", e);
      return Error(
        EmailLoginUnexpectedException("Ocorreu um erro inesperado."),
      );
    }
  }

  @override
  Future<Result<LoginResult, Exception>> loginWithGoogle(
    String googleServerCode,
  ) async {
    try {
      final result = await _apiGateway.post(
        GatewayRoutes.loginGoogle,
        data: {'tokenOauth': googleServerCode},
      );

      if (result.isError()) {
        _log.severe("Login Google tentativa falhou: ", result.tryGetError()!);
        return Result.error(
          Exception("Ocorreu um erro desconhecido ao fazer login."),
        );
      }

      final responseData = result.tryGetSuccess()!;
      final apiLoginResponse = LoginApiResponse.fromJson(responseData);
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
    await _apiGateway.post(GatewayRoutes.logout);
  }

  @override
  Future<Result<String, Exception>> register({
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String telefone,
    required String registerToken,
  }) async {
    final result = await _apiGateway.post(
      GatewayRoutes.registerUser,
      data: {
        'nome': nome,
        'cpf': cpf,
        'dataNascimento': dataNascimento.toIso8601String(),
        'telefone': telefone,
        'registerToken': registerToken,
      },
    );

    if (result.isError()) {
      return Result.error(result.tryGetError()!);
    }

    final responseData = result.tryGetSuccess()!;
    final registerResponse = RegisterResponse.fromJson(responseData);

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
    final result = await _apiGateway.post(
      GatewayRoutes.sendEmail,
      data: {'email': email},
    );

    if (result.isError()) {
      return Result.error(result.tryGetError()!);
    }

    return Result.success(null);
  }
}
