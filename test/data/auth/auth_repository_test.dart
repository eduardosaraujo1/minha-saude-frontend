import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/services/api/clients/auth/auth_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/api/clients/auth/models/login_response/login_api_response.dart';
import 'package:minha_saude_frontend/app/data/services/api/clients/auth/models/register_response/register_response.dart';
import 'package:minha_saude_frontend/app/data/services/google/google_service.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

class MockAuthApiClient extends Mock implements AuthApiClient {}

class MockGoogleService extends Mock implements GoogleService {}

void main() {
  /*
  ### Google Authentication
  - it returns server code when authentication succeeds
  - it returns error when Google returns null code
  - it returns error when Google returns empty code
  - it returns error when authentication fails
  - it returns session token for registered user (loginWithGoogle)
  - it returns register token for unregistered user (loginWithGoogle)
  - it returns error when API call fails (loginWithGoogle)
  - it returns error when API response is invalid (loginWithGoogle)

  ### Email Authentication
  - it sends email code successfully (requestEmailCode)
  - it returns error when email sending fails (requestEmailCode)
  - it returns session token for registered user (loginWithEmail)
  - it returns register token for unregistered user (loginWithEmail)
  - it returns appropriate error when API call fails (loginWithEmail)
  - it returns appropriate error when API returns incorrect code error (loginWithEmail)
  - it returns error when API response is invalid (loginWithEmail)

  ### Registration
  - it returns session token when registration succeeds
  - it returns error when session token is null
  - it returns error when session token is empty
  - it returns error when registration fails

  ### Session Management
  - it calls API logout
  */
  late MockAuthApiClient mockAuthApiClient;
  late MockGoogleService mockGoogleService;
  late AuthRepository authRepository;

  setUp(() {
    mockAuthApiClient = MockAuthApiClient();
    mockGoogleService = MockGoogleService();

    authRepository = AuthRepositoryImpl(
      apiClient: mockAuthApiClient,
      googleService: mockGoogleService,
    );
  });

  group("Google Authentication", () {
    test("it returns server code when authentication succeeds", () async {
      const serverCode = "test-server-code-123";
      when(
        () => mockGoogleService.generateServerAuthCode(),
      ).thenAnswer((_) async => const Result.success(serverCode));

      final result = await authRepository.getGoogleServerToken();

      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess(), serverCode);
      verify(() => mockGoogleService.generateServerAuthCode()).called(1);
    });

    test("it returns error when Google returns null code", () async {
      when(
        () => mockGoogleService.generateServerAuthCode(),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await authRepository.getGoogleServerToken();

      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Não foi possível autenticar-se com o Google'),
      );
    });

    test("it returns error when Google returns empty code", () async {
      when(
        () => mockGoogleService.generateServerAuthCode(),
      ).thenAnswer((_) async => const Result.success(""));

      final result = await authRepository.getGoogleServerToken();

      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Não foi possível autenticar-se com o Google'),
      );
    });

    test("it returns error when authentication fails", () async {
      when(() => mockGoogleService.generateServerAuthCode()).thenAnswer(
        (_) async => Result.error(Exception("Google authentication failed")),
      );

      final result = await authRepository.getGoogleServerToken();

      expect(result.isError(), true);
    });

    test("it returns session token for registered user", () async {
      const mockApiResponse = LoginApiResponse(
        isRegistered: true,
        sessionToken: "test-session-token",
        registerToken: null,
      );
      when(
        () => mockAuthApiClient.authLoginGoogle(any()),
      ).thenAnswer((_) async => const Result.success(mockApiResponse));

      final result = await authRepository.loginWithGoogle(
        "test-google-server-code",
      );

      expect(result.isSuccess(), true);
      final loginResult = result.tryGetSuccess()!;
      expect(loginResult, isA<SuccessfulLoginResult>());
      expect(
        (loginResult as SuccessfulLoginResult).sessionToken,
        "test-session-token",
      );
      verify(
        () => mockAuthApiClient.authLoginGoogle("test-google-server-code"),
      ).called(1);
    });

    test("it returns register token for unregistered user", () async {
      const mockApiResponse = LoginApiResponse(
        isRegistered: false,
        sessionToken: null,
        registerToken: "test-register-token",
      );
      when(
        () => mockAuthApiClient.authLoginGoogle(any()),
      ).thenAnswer((_) async => const Result.success(mockApiResponse));

      final result = await authRepository.loginWithGoogle(
        "test-google-server-code",
      );

      expect(result.isSuccess(), true);
      final loginResult = result.tryGetSuccess()!;
      expect(loginResult, isA<NeedsRegistrationLoginResult>());
      expect(
        (loginResult as NeedsRegistrationLoginResult).registerToken,
        "test-register-token",
      );
    });

    test("it returns error when API call fails", () async {
      final testError = Exception("Network error");
      when(
        () => mockAuthApiClient.authLoginGoogle(any()),
      ).thenAnswer((_) async => Result.error(testError));

      final result = await authRepository.loginWithGoogle(
        "test-google-server-code",
      );

      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Ocorreu um erro desconhecido ao fazer login'),
      );
    });

    test("it returns error when API response is invalid", () async {
      const mockApiResponse = LoginApiResponse(
        isRegistered: true,
        sessionToken: null,
        registerToken: null,
      );
      when(
        () => mockAuthApiClient.authLoginGoogle(any()),
      ).thenAnswer((_) async => const Result.success(mockApiResponse));

      final result = await authRepository.loginWithGoogle(
        "test-google-server-code",
      );

      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Ocorreu um erro ao fazer login'),
      );
    });
  });

  group("Email Authentication", () {
    test("it sends email code successfully", () async {
      when(
        () => mockAuthApiClient.authSendEmail(any()),
      ).thenAnswer((_) async => const Result.success(null));
      final result = await authRepository.requestEmailCode("test@example.com");

      expect(result.isSuccess(), true);
      verify(
        () => mockAuthApiClient.authSendEmail("test@example.com"),
      ).called(1);
    });

    test("it returns error when email sending fails", () async {
      when(
        () => mockAuthApiClient.authSendEmail(any()),
      ).thenAnswer((_) async => Error(Exception("Email sending failed")));

      final result = await authRepository.requestEmailCode("test@example.com");

      expect(result.isError(), true);
    });

    test("it returns session token for registered user", () async {
      const mockApiResponse = LoginApiResponse(
        isRegistered: true,
        sessionToken: "test-session-token",
        registerToken: null,
      );
      when(
        () => mockAuthApiClient.authLoginEmail(any(), any()),
      ).thenAnswer((_) async => const Result.success(mockApiResponse));

      // Act
      final result = await authRepository.loginWithEmail(
        "test@example.com",
        "123456",
      );

      final loginResult = result.tryGetSuccess();
      expect(result.isSuccess(), true);
      expect(loginResult, isA<SuccessfulLoginResult>());
      expect(
        (loginResult as SuccessfulLoginResult).sessionToken,
        "test-session-token",
      );
      verify(
        () => mockAuthApiClient.authLoginEmail("test@example.com", "123456"),
      ).called(1);
    });

    test("it returns register token for unregistered user", () async {
      const mockApiResponse = LoginApiResponse(
        isRegistered: false,
        sessionToken: null,
        registerToken: "test-register-token",
      );
      when(
        () => mockAuthApiClient.authLoginEmail(any(), any()),
      ).thenAnswer((_) async => const Result.success(mockApiResponse));

      final result = await authRepository.loginWithEmail(
        "test@example.com",
        "123456",
      );

      expect(result.isSuccess(), true);
      final loginResult = result.tryGetSuccess()!;
      expect(loginResult, isA<NeedsRegistrationLoginResult>());
      expect(
        (loginResult as NeedsRegistrationLoginResult).registerToken,
        "test-register-token",
      );
    });

    test(
      "it returns appropriate error when API returns incorrect code error",
      () async {
        final testError = ApiUnexpectedEmailLoginException("Unexpected Error");
        when(
          () => mockAuthApiClient.authLoginEmail(any(), any()),
        ).thenAnswer((_) async => Result.error(testError));

        final result = await authRepository.loginWithEmail(
          "test@example.com",
          "123456",
        );

        expect(result.isError(), true);
        expect(result.tryGetError(), isA<EmailLoginUnexpectedException>());
      },
    );

    test(
      "it returns appropriate error when API returns incorrect code error",
      () async {
        final testError = ApiEmailLoginIncorrectCodeException("Invalid code");
        when(
          () => mockAuthApiClient.authLoginEmail(any(), any()),
        ).thenAnswer((_) async => Result.error(testError));

        final result = await authRepository.loginWithEmail(
          "test@example.com",
          "123456",
        );

        expect(result.isError(), true);
        expect(result.tryGetError(), isA<EmailLoginIncorrectCodeException>());
      },
    );

    test("it returns error when API response is invalid", () async {
      const mockApiResponse = LoginApiResponse(
        isRegistered: false,
        sessionToken: null,
        registerToken: null,
      );
      when(
        () => mockAuthApiClient.authLoginEmail(any(), any()),
      ).thenAnswer((_) async => const Result.success(mockApiResponse));

      final result = await authRepository.loginWithEmail(
        "test@example.com",
        "123456",
      );

      expect(result.isError(), true);
    });
  });

  group("Registration", () {
    final testDate = DateTime(1990, 1, 1);

    setUp(() {
      when(
        () => mockAuthApiClient.authRegister(
          cpf: any(named: "cpf"),
          dataNascimento: any(named: "dataNascimento"),
          nome: any(named: "nome"),
          telefone: any(named: "telefone"),
          registerToken: any(named: "registerToken"),
        ),
      ).thenAnswer(
        (_) async => const Result.success(
          RegisterResponse(
            status: "success",
            sessionToken: "test-session-token-123",
          ),
        ),
      );
    });

    test("it returns session token when registration succeeds", () async {
      final result = await authRepository.register(
        registerToken: "test-register-token",
        nome: "John Doe",
        cpf: "12345678900",
        telefone: "11999999999",
        dataNascimento: testDate,
      );

      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess(), "test-session-token-123");
      verify(
        () => mockAuthApiClient.authRegister(
          registerToken: "test-register-token",
          nome: "John Doe",
          cpf: "12345678900",
          telefone: "11999999999",
          dataNascimento: testDate,
        ),
      ).called(1);
    });

    test("it returns error when session token is null", () async {
      when(
        () => mockAuthApiClient.authRegister(
          cpf: any(named: "cpf"),
          dataNascimento: any(named: "dataNascimento"),
          nome: any(named: "nome"),
          telefone: any(named: "telefone"),
          registerToken: any(named: "registerToken"),
        ),
      ).thenAnswer(
        (_) async => const Result.success(
          RegisterResponse(status: "success", sessionToken: null),
        ),
      );

      final result = await authRepository.register(
        registerToken: "test-register-token",
        nome: "John Doe",
        cpf: "12345678900",
        telefone: "11999999999",
        dataNascimento: testDate,
      );

      expect(result.isError(), true);
    });

    test("it returns error when session token is empty", () async {
      when(
        () => mockAuthApiClient.authRegister(
          cpf: any(named: "cpf"),
          dataNascimento: any(named: "dataNascimento"),
          nome: any(named: "nome"),
          telefone: any(named: "telefone"),
          registerToken: any(named: "registerToken"),
        ),
      ).thenAnswer(
        (_) async => const Result.success(
          RegisterResponse(status: "success", sessionToken: ""),
        ),
      );

      final result = await authRepository.register(
        registerToken: "test-register-token",
        nome: "John Doe",
        cpf: "12345678900",
        telefone: "11999999999",
        dataNascimento: testDate,
      );

      expect(result.isError(), true);
    });

    test("it returns error when registration fails", () async {
      when(
        () => mockAuthApiClient.authRegister(
          cpf: any(named: "cpf"),
          dataNascimento: any(named: "dataNascimento"),
          nome: any(named: "nome"),
          telefone: any(named: "telefone"),
          registerToken: any(named: "registerToken"),
        ),
      ).thenAnswer((_) async => Result.error(Exception("Registration failed")));

      final result = await authRepository.register(
        registerToken: "test-register-token",
        nome: "John Doe",
        cpf: "12345678900",
        telefone: "11999999999",
        dataNascimento: testDate,
      );

      expect(result.isError(), true);
    });
  });

  group("Session Management", () {
    test("it calls API logout", () async {
      when(
        () => mockAuthApiClient.authLogout(),
      ).thenAnswer((_) async => const Result.success(null));

      await authRepository.logout();

      verify(() => mockAuthApiClient.authLogout()).called(1);
    });
  });
}
