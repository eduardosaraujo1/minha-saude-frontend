import 'package:minha_saude_frontend/app/data/repositories/session/session_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../mocks/mock_secure_storage.dart';

void main() {
  late SessionRepository sessionRepository;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorage();
    sessionRepository = SessionRepositoryImpl(secureStorage: mockSecureStorage);
  });

  group("Persistent Auth Token Management", () {
    test(
      "when set method is called then it should store the auth token",
      () async {
        // Arrange
        const token = 'test_auth_token_123';
        when(
          () => mockSecureStorage.setAuthToken(any()),
        ).thenAnswer((_) async => const Success(null));

        // Act
        final result = await sessionRepository.setAuthToken(token);

        // Assert
        expect(result.isSuccess(), true);
        verify(() => mockSecureStorage.setAuthToken(token)).called(1);
      },
    );

    test(
      "when set method is called then get method should have same response",
      () async {
        // Arrange
        const token = 'test_auth_token_123';
        when(
          () => mockSecureStorage.setAuthToken(any()),
        ).thenAnswer((_) async => const Success(null));

        // Act
        await sessionRepository.setAuthToken(token);
        final result = await sessionRepository.getAuthToken();

        // Assert
        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), token);
      },
    );

    test(
      "when get method is called without set then it should return same value as secure storage",
      () async {
        // Arrange
        const token = 'stored_token_456';
        when(
          () => mockSecureStorage.getAuthToken(),
        ).thenAnswer((_) async => const Success('stored_token_456'));

        // Act
        final result = await sessionRepository.getAuthToken();

        // Assert
        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), token);
        verify(() => mockSecureStorage.getAuthToken()).called(1);
      },
    );

    test(
      "when set method and two get methods are called the secure storage should not have any reads (only writes)",
      () async {
        // Arrange
        const token = 'test_auth_token_789';
        when(
          () => mockSecureStorage.setAuthToken(any()),
        ).thenAnswer((_) async => const Success(null));

        // Act
        await sessionRepository.setAuthToken(token);
        await sessionRepository.getAuthToken();
        await sessionRepository.getAuthToken();

        // Assert
        verify(() => mockSecureStorage.setAuthToken(token)).called(1);
        verifyNever(() => mockSecureStorage.getAuthToken());
      },
    );

    test("when clear method is called get method should return null", () async {
      // Arrange
      const token = 'test_auth_token_clear';
      when(
        () => mockSecureStorage.setAuthToken(any()),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => mockSecureStorage.clearAuthToken(),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => mockSecureStorage.getAuthToken(),
      ).thenAnswer((_) async => const Success(null));

      // Act
      await sessionRepository.setAuthToken(token);
      await sessionRepository.clearAuthToken();
      final result = await sessionRepository.getAuthToken();

      // Assert
      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess(), null);
      verify(() => mockSecureStorage.clearAuthToken()).called(1);
    });

    test(
      "if setToken was called when hasToken method is called get it should return true",
      () async {
        // Arrange
        const token = 'test_auth_token_has';
        when(
          () => mockSecureStorage.setAuthToken(any()),
        ).thenAnswer((_) async => const Success(null));

        // Act
        await sessionRepository.setAuthToken(token);
        final hasToken = await sessionRepository.hasAuthToken();

        // Assert
        expect(hasToken, true);
      },
    );

    test(
      "if setToken was not called when hasToken method is called get it should return false",
      () async {
        // Arrange
        when(
          () => mockSecureStorage.getAuthToken(),
        ).thenAnswer((_) async => const Success(null));

        // Act
        final hasToken = await sessionRepository.hasAuthToken();

        // Assert
        expect(hasToken, false);
      },
    );
  });
  group("Ephemeral Register Token Management", () {
    // The tests in register token should be almost the same as the previous group
    // The difference is that register token is not persisted in secure storage
    // It is only stored in memory (so tests should not expect that)

    test(
      "when set method is called then it should store the register token",
      () {
        // Arrange
        const token = 'test_register_token_123';

        // Act
        sessionRepository.setRegisterToken(token);
        final result = sessionRepository.getRegisterToken();

        // Assert
        expect(result, token);
      },
    );

    test(
      "when set method is called then get method should have same response",
      () {
        // Arrange
        const token = 'test_register_token_456';

        // Act
        sessionRepository.setRegisterToken(token);
        final result = sessionRepository.getRegisterToken();

        // Assert
        expect(result, token);
      },
    );

    test(
      "when get method is called without set then it should return null",
      () {
        // Act
        final result = sessionRepository.getRegisterToken();

        // Assert
        expect(result, null);
      },
    );

    test(
      "when set method and two get methods are called the secure storage should not be accessed",
      () {
        // Arrange
        const token = 'test_register_token_789';

        // Act
        sessionRepository.setRegisterToken(token);
        sessionRepository.getRegisterToken();
        sessionRepository.getRegisterToken();

        // Assert - Verify no secure storage interactions happened
        verifyNever(() => mockSecureStorage.setAuthToken(any()));
        verifyNever(() => mockSecureStorage.getAuthToken());
        verifyNever(() => mockSecureStorage.clearAuthToken());
      },
    );

    test("when clear method is called get method should return null", () {
      // Arrange
      const token = 'test_register_token_clear';

      // Act
      sessionRepository.setRegisterToken(token);
      sessionRepository.clearRegisterToken();
      final result = sessionRepository.getRegisterToken();

      // Assert
      expect(result, null);
    });

    test(
      "if setRegisterToken was called when hasRegisterToken method is called it should return true",
      () {
        // Arrange
        const token = 'test_register_token_has';

        // Act
        sessionRepository.setRegisterToken(token);
        final hasToken = sessionRepository.hasRegisterToken();

        // Assert
        expect(hasToken, true);
      },
    );

    test(
      "if setRegisterToken was not called when hasRegisterToken method is called it should return false",
      () {
        // Act
        final hasToken = sessionRepository.hasRegisterToken();

        // Assert
        expect(hasToken, false);
      },
    );

    test(
      "if setRegisterToken with null was called when hasRegisterToken method is called it should return false",
      () {
        // Arrange
        sessionRepository.setRegisterToken('some_token');

        // Act
        sessionRepository.setRegisterToken(null);
        final hasToken = sessionRepository.hasRegisterToken();

        // Assert
        expect(hasToken, false);
      },
    );
  });

  test(
    "When logout is run then it should clear auth token and register token from cache and local storage",
    () async {
      // Arrange: Set initial tokens
      const authToken = 'test_auth_token_logout';
      const registerToken = 'test_register_token_logout';

      when(
        () => mockSecureStorage.setAuthToken(any()),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => mockSecureStorage.clearAuthToken(),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => mockSecureStorage.getAuthToken(),
      ).thenAnswer((_) async => const Success(null));

      await sessionRepository.setAuthToken(authToken);
      sessionRepository.setRegisterToken(registerToken);

      // Act: Call logout
      await sessionRepository.logout();

      // Assert: Check if tokens are cleared
      final authResult = await sessionRepository.getAuthToken();
      final registerResult = sessionRepository.getRegisterToken();
      final hasAuth = await sessionRepository.hasAuthToken();
      final hasRegister = sessionRepository.hasRegisterToken();

      expect(authResult.tryGetSuccess(), null);
      expect(registerResult, null);
      expect(hasAuth, false);
      expect(hasRegister, false);

      // Assert: Check if secure storage was called for clear
      verify(() => mockSecureStorage.clearAuthToken()).called(1);
    },
  );
}
