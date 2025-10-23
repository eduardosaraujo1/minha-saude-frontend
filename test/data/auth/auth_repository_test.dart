import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/services/api/gateway/api_gateway.dart';
import 'package:minha_saude_frontend/app/data/services/api/gateway/routes.dart';
import 'package:minha_saude_frontend/app/data/services/google/google_service.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

class MockGoogleService extends Mock implements GoogleService {}

class MockApiGateway extends Mock implements ApiGateway {}

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
  late MockGoogleService mockGoogleService;
  late MockApiGateway mockApiGateway;
  late AuthRepository authRepository;

  setUp(() {
    mockApiGateway = MockApiGateway();
    mockGoogleService = MockGoogleService();

    authRepository = AuthRepositoryImpl(
      apiGateway: mockApiGateway,
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
      const mockApiResponse = {
        'isRegistered': true,
        'sessionToken': 'test-session-token',
      };
      when(
        () => mockApiGateway.post(
          GatewayRoutes.loginGoogle,
          data: any(named: 'data'),
        ),
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
        () => mockApiGateway.post(
          GatewayRoutes.loginGoogle,
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test("it returns register token for unregistered user", () async {
      const mockApiResponse = {
        'isRegistered': false,
        'registerToken': 'test-register-token',
      };
      when(
        () => mockApiGateway.post(
          GatewayRoutes.loginGoogle,
          data: any(named: 'data'),
        ),
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
      final testError = ClientException("Network error");
      when(
        () => mockApiGateway.post(
          GatewayRoutes.loginGoogle,
          data: any(named: 'data'),
        ),
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
      const mockApiResponse = {'isRegistered': true};
      when(
        () => mockApiGateway.post(
          GatewayRoutes.loginGoogle,
          data: any(named: 'data'),
        ),
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
      const mockApiResponse = {'status': 'success'};
      when(
        () => mockApiGateway.post(
          GatewayRoutes.sendEmail,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => const Result.success(mockApiResponse));
      final result = await authRepository.requestEmailCode("test@example.com");

      expect(result.isSuccess(), true);
      verify(
        () => mockApiGateway.post(
          GatewayRoutes.sendEmail,
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test("it returns error when email sending fails", () async {
      when(
        () => mockApiGateway.post(
          GatewayRoutes.sendEmail,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => Error(ClientException("Email sending failed")));

      final result = await authRepository.requestEmailCode("test@example.com");

      expect(result.isError(), true);
    });

    test("it returns session token for registered user", () async {
      const mockApiResponse = {
        'isRegistered': true,
        'sessionToken': 'test-session-token',
      };
      when(
        () => mockApiGateway.post(
          GatewayRoutes.loginEmail,
          data: any(named: 'data'),
        ),
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
        () => mockApiGateway.post(
          GatewayRoutes.loginEmail,
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test("it returns register token for unregistered user", () async {
      const mockApiResponse = {
        'isRegistered': false,
        'registerToken': 'test-register-token',
      };
      when(
        () => mockApiGateway.post(
          GatewayRoutes.loginEmail,
          data: any(named: 'data'),
        ),
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
      "it returns appropriate error when API returns unexpected error",
      () async {
        final testError = ClientException(
          "Client error: 500 - Internal Server Error",
        );
        when(
          () => mockApiGateway.post(
            GatewayRoutes.loginEmail,
            data: any(named: 'data'),
          ),
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
        final testError = ClientException("Client error: 400 - Bad Request");
        when(
          () => mockApiGateway.post(
            GatewayRoutes.loginEmail,
            data: any(named: 'data'),
          ),
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
      const mockApiResponse = {'isRegistered': false};
      when(
        () => mockApiGateway.post(
          GatewayRoutes.loginEmail,
          data: any(named: 'data'),
        ),
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
      const mockApiResponse = {
        'status': 'success',
        'sessionToken': 'test-session-token-123',
      };
      when(
        () => mockApiGateway.post(
          GatewayRoutes.registerUser,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => const Result.success(mockApiResponse));
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
        () => mockApiGateway.post(
          GatewayRoutes.registerUser,
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test("it returns error when session token is null", () async {
      const mockApiResponse = {'status': 'success'};
      when(
        () => mockApiGateway.post(
          GatewayRoutes.registerUser,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => const Result.success(mockApiResponse));

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
      const mockApiResponse = {'status': 'success', 'sessionToken': ''};
      when(
        () => mockApiGateway.post(
          GatewayRoutes.registerUser,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => const Result.success(mockApiResponse));

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
        () => mockApiGateway.post(
          GatewayRoutes.registerUser,
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Result.error(ClientException("Registration failed")),
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
  });

  group("Session Management", () {
    test("it calls API logout", () async {
      const mockApiResponse = {'status': 'success'};
      when(
        () =>
            mockApiGateway.post(GatewayRoutes.logout, data: any(named: 'data')),
      ).thenAnswer((_) async => const Result.success(mockApiResponse));

      await authRepository.logout();

      verify(
        () =>
            mockApiGateway.post(GatewayRoutes.logout, data: any(named: 'data')),
      ).called(1);
    });
  });
}
