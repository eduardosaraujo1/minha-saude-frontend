import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/process_login_result_action.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../testing/mocks/repositories/mock_session_repository.dart';

void main() {
  late ProcessLoginResultAction processLoginResultAction;
  late MockSessionRepository mockSessionRepository;

  const SuccessfulLoginResult successfulLogin =
      LoginResult.successful(sessionToken: "valid-session-token-123")
          as SuccessfulLoginResult;
  const NeedsRegistrationLoginResult needsRegistrationLogin =
      LoginResult.needsRegistration(registerToken: "register-token-456")
          as NeedsRegistrationLoginResult;

  setUp(() {
    mockSessionRepository = MockSessionRepository();

    // Arrange: It successfully stores correct session token
    when(
      () => mockSessionRepository.setAuthToken(
        any(that: isNot(successfulLogin.sessionToken)),
      ),
    ).thenAnswer((_) async => Error(Exception("Invalid session token")));
    when(
      () => mockSessionRepository.setAuthToken(successfulLogin.sessionToken),
    ).thenAnswer((_) async => const Success(null));

    // Arrange: It successfully stores correct session token
    when(
      () => mockSessionRepository.setRegisterToken(
        any(that: isNot(needsRegistrationLogin.registerToken)),
      ),
    ).thenThrow(Exception("Invalid register token"));
    when(
      () => mockSessionRepository.setRegisterToken(
        needsRegistrationLogin.registerToken,
      ),
    ).thenAnswer((_) async => const Success(null));

    processLoginResultAction = ProcessLoginResultAction(
      sessionRepository: mockSessionRepository,
    );
  });

  /** Business Requirements
   * It stores the session token when login is successful
   * It stores the registration token when login requires registration
   * It handles errors when storing auth token fails
   * It handles errors when storing register token fails
   */

  group("Success Cases", () {
    test("It stores the session token when login is successful", () async {
      // Act
      final result = await processLoginResultAction.execute(successfulLogin);

      // Assert
      expect(result.isSuccess(), true);
      verify(
        () => mockSessionRepository.setAuthToken(successfulLogin.sessionToken),
      ).called(1);
      verifyNever(() => mockSessionRepository.setRegisterToken(any()));
    });

    test(
      "It stores the registration token when login requires registration",
      () async {
        // Act
        final result = await processLoginResultAction.execute(
          needsRegistrationLogin,
        );

        // Assert
        expect(result.isSuccess(), true);
        verify(
          () => mockSessionRepository.setRegisterToken(
            needsRegistrationLogin.registerToken,
          ),
        ).called(1);
        verifyNever(() => mockSessionRepository.setAuthToken(any()));
      },
    );
  });

  group("Error Handling", () {
    test("It handles errors when storing auth token fails", () async {
      // Arrange
      when(
        () => mockSessionRepository.setAuthToken(any()),
      ).thenAnswer((_) async => Error(Exception("Storage error")));

      // Act
      final result = await processLoginResultAction.execute(successfulLogin);

      // Assert
      expect(result.isError(), true);
    });

    test("It handles errors when storing register token fails", () async {
      // Arrange
      when(
        () => mockSessionRepository.setRegisterToken(any()),
      ).thenThrow(Exception("Storage error"));

      // Act
      final result = await processLoginResultAction.execute(
        needsRegistrationLogin,
      );

      // Assert
      expect(result.isError(), true);
    });
  });
}
