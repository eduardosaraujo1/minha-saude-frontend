import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/session/session_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/login_with_google.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late LoginWithGoogle loginWithGoogle;

  setUp(() {
    authRepository = MockAuthRepository();
    sessionRepository = MockSessionRepository();
    loginWithGoogle = LoginWithGoogle(
      authRepository: authRepository,
      sessionRepository: sessionRepository,
    );

    // Default mock behaviors (can be overridden in individual tests)
    when(
      () => authRepository.getGoogleServerToken(),
    ).thenAnswer((_) async => const Result.success("test-google-server-token"));

    when(() => authRepository.loginWithGoogle(any())).thenAnswer(
      (_) async => const Result.success(
        LoginResult.successful(sessionToken: "test-session-token-123"),
      ),
    );

    when(
      () => sessionRepository.setAuthToken(any()),
    ).thenAnswer((_) async => const Result.success(null));

    when(() => sessionRepository.setRegisterToken(any())).thenAnswer((_) {});

    when(
      () => sessionRepository.clearAuthToken(),
    ).thenAnswer((_) async => const Result.success(null));

    when(() => sessionRepository.clearRegisterToken()).thenAnswer((_) {});
  });

  test(
    "when Google auth succeeds and user is registered then it should store session token, clear register token and redirect to home",
    () async {
      // Execute action
      final result = await loginWithGoogle.execute();

      // Assert result is Success with redirect to home
      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess(), RedirectResponse.toHome);

      // Assert AuthRepository methods were called in order
      verify(() => authRepository.getGoogleServerToken()).called(1);
      verify(
        () => authRepository.loginWithGoogle("test-google-server-token"),
      ).called(1);

      // Assert SessionRepository.setAuthToken was called with correct token
      verify(
        () => sessionRepository.setAuthToken("test-session-token-123"),
      ).called(1);

      // Assert SessionRepository.clearRegisterToken was called
      verify(() => sessionRepository.clearRegisterToken()).called(1);
    },
  );

  test(
    "when Google auth succeeds but user needs registration then it should set register token, clear auth token and redirect to register",
    () async {
      // Override to return NeedsRegistrationLoginResult
      const loginResult = LoginResult.needsRegistration(
        registerToken: "test-register-token-456",
      );
      when(
        () => authRepository.loginWithGoogle(any()),
      ).thenAnswer((_) async => const Result.success(loginResult));

      // Execute action
      final result = await loginWithGoogle.execute();

      // Assert result is Success with redirect to register
      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess(), RedirectResponse.toRegister);

      // Assert AuthRepository methods were called
      verify(() => authRepository.getGoogleServerToken()).called(1);
      verify(
        () => authRepository.loginWithGoogle("test-google-server-token"),
      ).called(1);

      // Assert SessionRepository.setRegisterToken was called with correct token
      verify(
        () => sessionRepository.setRegisterToken("test-register-token-456"),
      ).called(1);

      // Assert SessionRepository.clearAuthToken was called
      verify(() => sessionRepository.clearAuthToken()).called(1);
    },
  );

  test(
    "when getGoogleServerToken fails then it should return Error without calling login",
    () async {
      // Override to return Error
      final testError = Exception("Google authentication failed");
      when(
        () => authRepository.getGoogleServerToken(),
      ).thenAnswer((_) async => Result.error(testError));

      // Execute action
      final result = await loginWithGoogle.execute();

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Não foi possível autenticar-se com o Google'),
      );

      // Assert AuthRepository.getGoogleServerToken was called
      verify(() => authRepository.getGoogleServerToken()).called(1);

      // Assert AuthRepository.loginWithGoogle was never called
      verifyNever(() => authRepository.loginWithGoogle(any()));
    },
  );

  test(
    "when loginWithGoogle fails then it should return Error without storing tokens",
    () async {
      // Override to return Error
      final testError = Exception("Login failed");
      when(
        () => authRepository.loginWithGoogle(any()),
      ).thenAnswer((_) async => Result.error(testError));

      // Execute action
      final result = await loginWithGoogle.execute();

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Não foi possível fazer login com o Google'),
      );

      // Assert AuthRepository methods were called
      verify(() => authRepository.getGoogleServerToken()).called(1);
      verify(
        () => authRepository.loginWithGoogle("test-google-server-token"),
      ).called(1);

      // Assert SessionRepository methods were never called
      verifyNever(() => sessionRepository.setAuthToken(any()));
      verifyNever(() => sessionRepository.setRegisterToken(any()));
    },
  );

  test(
    "when setAuthToken fails after successful login then it should return Error",
    () async {
      // Override to return Error
      final testError = Exception("Failed to store token");
      when(
        () => sessionRepository.setAuthToken(any()),
      ).thenAnswer((_) async => Result.error(testError));

      // Execute action
      final result = await loginWithGoogle.execute();

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Não foi possível salvar as credenciais de autenticação'),
      );

      // Assert methods were called
      verify(() => authRepository.getGoogleServerToken()).called(1);
      verify(
        () => authRepository.loginWithGoogle("test-google-server-token"),
      ).called(1);
      verify(
        () => sessionRepository.setAuthToken("test-session-token-123"),
      ).called(1);
    },
  );

  test(
    "when clearAuthToken fails during registration flow then it should return Error",
    () async {
      // Override to return NeedsRegistrationLoginResult
      const loginResult = LoginResult.needsRegistration(
        registerToken: "test-register-token-456",
      );
      when(
        () => authRepository.loginWithGoogle(any()),
      ).thenAnswer((_) async => const Result.success(loginResult));

      // Override to return Error
      final testError = Exception("Failed to clear token");
      when(
        () => sessionRepository.clearAuthToken(),
      ).thenAnswer((_) async => Result.error(testError));

      // Execute action
      final result = await loginWithGoogle.execute();

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Não foi possível limpar o token de autenticação atual'),
      );

      // Assert methods were called
      verify(() => authRepository.getGoogleServerToken()).called(1);
      verify(
        () => authRepository.loginWithGoogle("test-google-server-token"),
      ).called(1);
      verify(
        () => sessionRepository.setRegisterToken("test-register-token-456"),
      ).called(1);
      verify(() => sessionRepository.clearAuthToken()).called(1);
    },
  );
}
