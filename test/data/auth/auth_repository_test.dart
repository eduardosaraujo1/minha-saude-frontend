import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/services/api/auth/auth_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/api/auth/models/login_response/login_api_response.dart';
import 'package:minha_saude_frontend/app/data/services/api/auth/models/register_response/register_response.dart';
import 'package:minha_saude_frontend/app/data/services/google/google_service.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

class MockAuthApiClient extends Mock implements AuthApiClient {}

class MockGoogleService extends Mock implements GoogleService {}

void main() {
  late AuthApiClient authApiClient;
  late GoogleService googleService;
  late AuthRepository authRepository;

  setUp(() {
    authApiClient = MockAuthApiClient();
    googleService = MockGoogleService();

    authRepository = AuthRepositoryImpl(
      apiClient: authApiClient,
      googleService: googleService,
    );
  });

  group("getGoogleServerToken", () {
    test(
      "when GoogleService returns a valid server code then it should return Success with the code",
      () async {
        // Hook GoogleService to return a valid server code
        const serverCode = "test-server-code-123";
        when(
          () => googleService.generateServerAuthCode(),
        ).thenAnswer((_) async => const Result.success(serverCode));

        // Call getGoogleServerToken
        final result = await authRepository.getGoogleServerToken();

        // Assert method returned Success with the server code
        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), serverCode);

        // Assert GoogleService generateServerAuthCode was called once
        verify(() => googleService.generateServerAuthCode()).called(1);
      },
    );

    test(
      "when GoogleService returns null server code then it should return Error",
      () async {
        // Hook GoogleService to return null
        when(
          () => googleService.generateServerAuthCode(),
        ).thenAnswer((_) async => const Result.success(null));

        // Call getGoogleServerToken
        final result = await authRepository.getGoogleServerToken();

        // Assert method returned Error
        expect(result.isError(), true);
        expect(
          result.tryGetError()!.toString(),
          contains('Não foi possível autenticar-se com o Google'),
        );
      },
    );

    test(
      "when GoogleService returns empty server code then it should return Error",
      () async {
        // Hook GoogleService to return empty string
        when(
          () => googleService.generateServerAuthCode(),
        ).thenAnswer((_) async => const Result.success(""));

        // Call getGoogleServerToken
        final result = await authRepository.getGoogleServerToken();

        // Assert method returned Error
        expect(result.isError(), true);
        expect(
          result.tryGetError()!.toString(),
          contains('Não foi possível autenticar-se com o Google'),
        );
      },
    );

    test(
      "when GoogleService returns Error then it should propagate the error",
      () async {
        // Hook GoogleService to return Error
        final testError = Exception("Google authentication failed");
        when(
          () => googleService.generateServerAuthCode(),
        ).thenAnswer((_) async => Result.error(testError));

        // Call getGoogleServerToken
        final result = await authRepository.getGoogleServerToken();

        // Assert method returned Error
        expect(result.isError(), true);
        expect(result.tryGetError(), testError);
      },
    );
  });

  group("loginWithGoogle", () {
    test(
      "when API returns successful login response then it should return Success with LoginResult",
      () async {
        // Hook ApiClient to return successful login response
        const mockApiResponse = LoginApiResponse(
          isRegistered: true,
          sessionToken: "test-session-token",
          registerToken: null,
        );

        when(
          () => authApiClient.authLoginGoogle(any()),
        ).thenAnswer((_) async => const Result.success(mockApiResponse));

        // Call loginWithGoogle
        final result = await authRepository.loginWithGoogle(
          "test-google-server-code",
        );

        // Assert method returned Success with SuccessfulLoginResult
        expect(result.isSuccess(), true);
        final loginResult = result.tryGetSuccess()!;
        expect(loginResult, isA<SuccessfulLoginResult>());
        expect(
          (loginResult as SuccessfulLoginResult).sessionToken,
          "test-session-token",
        );

        // Assert ApiClient authLoginGoogle was called once
        verify(
          () => authApiClient.authLoginGoogle("test-google-server-code"),
        ).called(1);
      },
    );

    test(
      "when API returns needs registration response then it should return Success with NeedsRegistrationLoginResult",
      () async {
        // Hook ApiClient to return needs registration response
        const mockApiResponse = LoginApiResponse(
          isRegistered: false,
          sessionToken: null,
          registerToken: "test-register-token",
        );

        when(
          () => authApiClient.authLoginGoogle(any()),
        ).thenAnswer((_) async => const Result.success(mockApiResponse));

        // Call loginWithGoogle
        final result = await authRepository.loginWithGoogle(
          "test-google-server-code",
        );

        // Assert method returned Success with NeedsRegistrationLoginResult
        expect(result.isSuccess(), true);
        final loginResult = result.tryGetSuccess()!;
        expect(loginResult, isA<NeedsRegistrationLoginResult>());
        expect(
          (loginResult as NeedsRegistrationLoginResult).registerToken,
          "test-register-token",
        );
      },
    );

    test("when API returns Error then it should return Error", () async {
      // Hook ApiClient to return Error
      final testError = Exception("Network error");
      when(
        () => authApiClient.authLoginGoogle(any()),
      ).thenAnswer((_) async => Result.error(testError));

      // Call loginWithGoogle
      final result = await authRepository.loginWithGoogle(
        "test-google-server-code",
      );

      // Assert method returned Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Ocorreu um erro desconhecido ao fazer login'),
      );
    });

    test(
      "when API returns invalid response then it should return Error",
      () async {
        // Hook ApiClient to return invalid response (isRegistered true but no sessionToken)
        const mockApiResponse = LoginApiResponse(
          isRegistered: true,
          sessionToken: null,
          registerToken: null,
        );

        when(
          () => authApiClient.authLoginGoogle(any()),
        ).thenAnswer((_) async => const Result.success(mockApiResponse));

        // Call loginWithGoogle
        final result = await authRepository.loginWithGoogle(
          "test-google-server-code",
        );

        // Assert method returned Error
        expect(result.isError(), true);
        expect(
          result.tryGetError()!.toString(),
          contains('Ocorreu um erro ao fazer login'),
        );
      },
    );
  });

  group("loginWithEmail", () {
    test(
      "when API returns successful login response then it should return Success with LoginResult",
      () async {
        // Hook ApiClient to return successful login response
        const mockApiResponse = LoginApiResponse(
          isRegistered: true,
          sessionToken: "test-session-token",
          registerToken: null,
        );

        when(
          () => authApiClient.authLoginEmail(any(), any()),
        ).thenAnswer((_) async => const Result.success(mockApiResponse));

        // Call loginWithEmail
        final result = await authRepository.loginWithEmail(
          "test@example.com",
          "123456",
        );

        // Assert method returned Success with SuccessfulLoginResult
        expect(result.isSuccess(), true);
        final loginResult = result.tryGetSuccess()!;
        expect(loginResult, isA<SuccessfulLoginResult>());
        expect(
          (loginResult as SuccessfulLoginResult).sessionToken,
          "test-session-token",
        );

        // Assert ApiClient authLoginEmail was called once with correct parameters
        verify(
          () => authApiClient.authLoginEmail("test@example.com", "123456"),
        ).called(1);
      },
    );

    test(
      "when API returns needs registration response then it should return Success with NeedsRegistrationLoginResult",
      () async {
        // Hook ApiClient to return needs registration response
        const mockApiResponse = LoginApiResponse(
          isRegistered: false,
          sessionToken: null,
          registerToken: "test-register-token",
        );

        when(
          () => authApiClient.authLoginEmail(any(), any()),
        ).thenAnswer((_) async => const Result.success(mockApiResponse));

        // Call loginWithEmail
        final result = await authRepository.loginWithEmail(
          "test@example.com",
          "123456",
        );

        // Assert method returned Success with NeedsRegistrationLoginResult
        expect(result.isSuccess(), true);
        final loginResult = result.tryGetSuccess()!;
        expect(loginResult, isA<NeedsRegistrationLoginResult>());
        expect(
          (loginResult as NeedsRegistrationLoginResult).registerToken,
          "test-register-token",
        );
      },
    );

    test("when API returns Error then it should return Error", () async {
      // Hook ApiClient to return Error
      final testError = Exception("Invalid code");
      when(
        () => authApiClient.authLoginEmail(any(), any()),
      ).thenAnswer((_) async => Result.error(testError));

      // Call loginWithEmail
      final result = await authRepository.loginWithEmail(
        "test@example.com",
        "123456",
      );

      // Assert method returned Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Ocorreu um erro desconhecido ao fazer login'),
      );
    });

    test(
      "when API returns invalid response then it should return Error",
      () async {
        // Hook ApiClient to return invalid response (isRegistered false but no registerToken)
        const mockApiResponse = LoginApiResponse(
          isRegistered: false,
          sessionToken: null,
          registerToken: null,
        );

        when(
          () => authApiClient.authLoginEmail(any(), any()),
        ).thenAnswer((_) async => const Result.success(mockApiResponse));

        // Call loginWithEmail
        final result = await authRepository.loginWithEmail(
          "test@example.com",
          "123456",
        );

        // Assert method returned Error
        expect(result.isError(), true);
        expect(
          result.tryGetError()!.toString(),
          contains('Ocorreu um erro ao fazer login'),
        );
      },
    );
  });

  group("requestEmailCode", () {
    test(
      "when API successfully sends email code then it should return Success",
      () async {
        // Hook ApiClient to return Success
        when(
          () => authApiClient.authSendEmail(any()),
        ).thenAnswer((_) async => const Result.success("code-sent"));

        // Call requestEmailCode
        final result = await authRepository.requestEmailCode(
          "test@example.com",
        );

        // Assert method returned Success
        expect(result.isSuccess(), true);

        // Assert ApiClient authSendEmail was called once with correct email
        verify(() => authApiClient.authSendEmail("test@example.com")).called(1);
      },
    );

    test("when API returns Error then it should return Error", () async {
      // Hook ApiClient to return Error
      final testError = Exception("Email sending failed");
      when(
        () => authApiClient.authSendEmail(any()),
      ).thenAnswer((_) async => Result.error(testError));

      // Call requestEmailCode
      final result = await authRepository.requestEmailCode("test@example.com");

      // Assert method returned Error
      expect(result.isError(), true);
      expect(result.tryGetError(), testError);
    });
  });

  group("register", () {
    test(
      "when API returns successful registration with session token then it should return Success with token",
      () async {
        // Hook ApiClient to return successful registration response
        const mockRegisterResponse = RegisterResponse(
          status: "success",
          sessionToken: "test-session-token-123",
        );

        when(
          () => authApiClient.authRegister(
            cpf: any(named: "cpf"),
            dataNascimento: any(named: "dataNascimento"),
            nome: any(named: "nome"),
            telefone: any(named: "telefone"),
            registerToken: any(named: "registerToken"),
          ),
        ).thenAnswer((_) async => const Result.success(mockRegisterResponse));

        // Call register
        final result = await authRepository.register(
          registerToken: "test-register-token",
          nome: "John Doe",
          cpf: "12345678900",
          telefone: "11999999999",
          dataNascimento: DateTime(1990, 1, 1),
        );

        // Assert method returned Success with session token
        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), "test-session-token-123");

        // Assert ApiClient authRegister was called once with correct model
        verify(
          () => authApiClient.authRegister(
            registerToken: "test-register-token",
            nome: "John Doe",
            cpf: "12345678900",
            telefone: "11999999999",
            dataNascimento: DateTime(1990, 1, 1),
          ),
        ).called(1);
      },
    );

    test(
      "when API returns response with null session token then it should return Error",
      () async {
        // Hook ApiClient to return response with null sessionToken
        const mockRegisterResponse = RegisterResponse(
          status: "success",
          sessionToken: null,
        );

        when(
          () => authApiClient.authRegister(
            cpf: any(named: "cpf"),
            dataNascimento: any(named: "dataNascimento"),
            nome: any(named: "nome"),
            telefone: any(named: "telefone"),
            registerToken: any(named: "registerToken"),
          ),
        ).thenAnswer((_) async => const Result.success(mockRegisterResponse));

        // Call register
        final result = await authRepository.register(
          registerToken: "test-register-token",
          nome: "John Doe",
          cpf: "12345678900",
          telefone: "11999999999",
          dataNascimento: DateTime(1990, 1, 1),
        );

        // Assert method returned Error
        expect(result.isError(), true);
        expect(
          result.tryGetError()!.toString(),
          contains('Ocorreu um erro desconhecido ao tentar registrar'),
        );
      },
    );

    test(
      "when API returns response with empty session token then it should return Error",
      () async {
        // Hook ApiClient to return response with empty sessionToken
        const mockRegisterResponse = RegisterResponse(
          status: "success",
          sessionToken: "",
        );

        when(
          () => authApiClient.authRegister(
            cpf: any(named: "cpf"),
            dataNascimento: any(named: "dataNascimento"),
            nome: any(named: "nome"),
            telefone: any(named: "telefone"),
            registerToken: any(named: "registerToken"),
          ),
        ).thenAnswer((_) async => const Result.success(mockRegisterResponse));

        // Call register
        final result = await authRepository.register(
          registerToken: "test-register-token",
          nome: "John Doe",
          cpf: "12345678900",
          telefone: "11999999999",
          dataNascimento: DateTime(1990, 1, 1),
        );

        // Assert method returned Error
        expect(result.isError(), true);
        expect(
          result.tryGetError()!.toString(),
          contains('Ocorreu um erro desconhecido ao tentar registrar'),
        );
      },
    );

    test("when API returns Error then it should propagate the error", () async {
      // Hook ApiClient to return Error
      final testError = Exception("Registration failed");
      when(
        () => authApiClient.authRegister(
          cpf: any(named: "cpf"),
          dataNascimento: any(named: "dataNascimento"),
          nome: any(named: "nome"),
          telefone: any(named: "telefone"),
          registerToken: any(named: "registerToken"),
        ),
      ).thenAnswer((_) async => Result.error(testError));

      // Call register
      final result = await authRepository.register(
        registerToken: "test-register-token",
        nome: "John Doe",
        cpf: "12345678900",
        telefone: "11999999999",
        dataNascimento: DateTime(1990, 1, 1),
      );

      // Assert method returned Error
      expect(result.isError(), true);
      expect(result.tryGetError(), testError);
    });
  });

  group("logout", () {
    test(
      "when logout is called then it should call authLogout on ApiClient",
      () async {
        // Hook ApiClient to detect authLogout call
        when(
          () => authApiClient.authLogout(),
        ).thenAnswer((_) async => const Result.success(null));

        // Call logout
        await authRepository.logout();

        // Assert ApiClient authLogout was called once
        verify(() => authApiClient.authLogout()).called(1);
      },
    );
  });
}
