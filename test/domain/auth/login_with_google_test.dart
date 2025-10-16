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
  /* Business Expectations:
   * Should use google auth to get server token
   * Should call loginWithGoogle with token from google auth
   * If user is registered, should store auth token and return SuccessfulLoginResult
   * If user is not registered, should store register token and return NeedsRegistrationLoginResult
   * Should handle errors gracefully and return Error with appropriate message
   */
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late LoginWithGoogle loginWithGoogle;
  late String expectedGoogleToken;
  late String expectedServerToken;

  setUp(() {
    authRepository = MockAuthRepository();
    sessionRepository = MockSessionRepository();
    loginWithGoogle = LoginWithGoogle(
      authRepository: authRepository,
      sessionRepository: sessionRepository,
    );

    expectedGoogleToken = "test-google-server-token";
    expectedServerToken = "test-server-token-123";

    // Successful Google auth
    when(
      () => authRepository.getGoogleServerToken(),
    ).thenAnswer((_) async => Success(expectedGoogleToken));

    // Successful server login
    when(() => authRepository.loginWithGoogle(any())).thenAnswer(
      (_) async =>
          Success(LoginResult.successful(sessionToken: expectedServerToken)),
    );

    // Successful token storage
    when(
      () => sessionRepository.setAuthToken(any()),
    ).thenAnswer((_) async => const Success(null));
  });

  group("Existing user tests", () {
    test("should return successful login response", () async {
      // Execute action
      final result = await loginWithGoogle.execute();

      // Assert result is Success with redirect to home
      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess(), isA<SuccessfulLoginResult>());

      // Must be called as a requirement for google login
      // If this fails it may be because the repository was bypassed and the service was used directly
      // ALWAYS prefer to use the repository for modularization
      verify(() => authRepository.getGoogleServerToken()).called(1);

      // Login must be called with the token obtained from getGoogleServerToken
      verify(
        () => authRepository.loginWithGoogle(expectedGoogleToken),
      ).called(1);
    });
    test("should store auth token", () async {
      // Execute action
      await loginWithGoogle.execute();

      // Assert SessionRepository.setAuthToken was called with correct token
      verify(
        () => sessionRepository.setAuthToken(expectedServerToken),
      ).called(1);
    });

    test("should not store register token", () async {
      // Execute action
      await loginWithGoogle.execute();

      // Assert SessionRepository.setAuthToken was called with correct token
      verifyNever(() => sessionRepository.setRegisterToken(any()));
    });
  });

  group("New user tests", () {
    setUp(() {
      // Unregistered server login attempt
      expectedServerToken = "test-register-token-123";
      when(() => authRepository.loginWithGoogle(any())).thenAnswer(
        (_) async => Success(
          LoginResult.needsRegistration(registerToken: expectedServerToken),
        ),
      );
    });
    test("should return needs registration result", () async {
      // Execute action
      final result = await loginWithGoogle.execute();

      // Assert result is Success with redirect to home
      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess(), isA<NeedsRegistrationLoginResult>());

      // Must be called as a requirement for google login
      // If this fails it may be because the repository was bypassed and the service was used directly
      // ALWAYS prefer to use the repository for modular design
      verify(() => authRepository.getGoogleServerToken()).called(1);

      // Login must be called with the token obtained from getGoogleServerToken
      verify(
        () => authRepository.loginWithGoogle(expectedGoogleToken),
      ).called(1);
    });
    test("should store register token", () async {
      // Execute action
      await loginWithGoogle.execute();

      // Requirement: register token should be registered for future usage in the registration flow
      verify(
        () => sessionRepository.setRegisterToken(expectedServerToken),
      ).called(1);
    });
    test("should not store auth token", () async {
      // Execute action
      await loginWithGoogle.execute();

      verifyNever(() => sessionRepository.setAuthToken(any()));
    });
  });

  group("Google error handling", () {
    setUp(() {
      when(() => authRepository.getGoogleServerToken()).thenAnswer(
        (_) async =>
            Error(Exception("Não foi possível autenticar-se com o Google.")),
      );
    });

    test("handles google auth failure gracefully", () async {
      // Act
      final result = await loginWithGoogle.execute();

      // Assert
      expect(result.isError(), true);

      // Attempt to get token must have been made, otherwise error may have come from elsewhere
      verify(() => authRepository.getGoogleServerToken()).called(1);

      // Must not attempt to login if token retrieval failed
      verifyNever(() => authRepository.loginWithGoogle(any()));

      // Must not attempt to store tokens if login failed
      verifyNever(() => sessionRepository.setAuthToken(any()));
      verifyNever(() => sessionRepository.setRegisterToken(any()));
    });
  });

  group("Server error handling", () {
    setUp(() {
      when(() => authRepository.loginWithGoogle(any())).thenAnswer(
        (_) async =>
            Error(Exception("Não foi possível fazer login no servidor.")),
      );
    });

    test("handles server failure gracefully", () async {
      // Act
      final result = await loginWithGoogle.execute();

      // Assert
      expect(result.isError(), true);

      // Must have attempted to get token and login
      verify(() => authRepository.getGoogleServerToken()).called(1);
      verify(
        () => authRepository.loginWithGoogle(expectedGoogleToken),
      ).called(1);

      // Must not attempt to store tokens if login failed
      verifyNever(() => sessionRepository.setAuthToken(any()));
      verifyNever(() => sessionRepository.setRegisterToken(any()));
    });
  });

  group("Token storage error handling", () {
    setUp(() {
      when(() => sessionRepository.setAuthToken(any())).thenAnswer(
        (_) async => Error(Exception("Não foi possível armazenar o token.")),
      );

      when(
        () => sessionRepository.setRegisterToken(any()),
      ).thenThrow(Exception("Não foi possível armazenar o token."));
    });

    test("handles token storage error gracefully (registered user)", () async {
      // Execute action
      final result = await loginWithGoogle.execute();

      // Assert
      expect(result.isError(), true);

      // If previous tests passed but this one failed, then the error should come from
      // sessionRepository.setAuthToken()
      verify(
        () => sessionRepository.setAuthToken(expectedServerToken),
      ).called(1);
    });

    test("handles token storage error gracefully (unregistered user)", () async {
      // Arrange
      expectedServerToken = "test-register-token-123";
      when(() => authRepository.loginWithGoogle(any())).thenAnswer(
        (_) async => Success(
          LoginResult.needsRegistration(registerToken: expectedServerToken),
        ),
      );

      // Execute action
      final result = await loginWithGoogle.execute();

      // Assert
      expect(result.isError(), true);

      // If previous tests passed but this one failed, then the error should come from
      // sessionRepository.setRegisterToken()
      verify(
        () => sessionRepository.setRegisterToken(expectedServerToken),
      ).called(1);
    });
  });
}
