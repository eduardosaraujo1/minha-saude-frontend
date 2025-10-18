import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/email_auth_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../../testing/mocks/actions/mock_process_login_result_action.dart';
import '../../../../testing/mocks/repositories/mock_auth_repository.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockProcessLoginResultAction mockProcessLoginResultAction;
  late EmailAuthViewModel viewModel;
  const LoginResult serverSuccessLogin = LoginResult.successful(
    sessionToken: "valid-session-token-123",
  );
  const LoginResult serverNeedsRegister = LoginResult.needsRegistration(
    registerToken: "register-token-123",
  );
  const String serverCode = "123456";
  const String email = "test@example.com";

  setUpAll(() {
    registerFallbackValue(
      const LoginResult.successful(sessionToken: "default-session-token"),
    );
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockProcessLoginResultAction = MockProcessLoginResultAction();
    viewModel = EmailAuthViewModel(
      authRepository: mockAuthRepository,
      processLoginResultAction: mockProcessLoginResultAction,
    );

    // Arrange: successful sending of email verification code
    when(
      () => mockAuthRepository.requestEmailCode(email),
    ).thenAnswer((_) async => const Success(null));

    // Arrange: successful login with email
    when(
      () => mockAuthRepository.loginWithEmail(email, serverCode),
    ).thenAnswer((_) async => const Success(serverSuccessLogin));

    // Arrange: successful processing of login result
    when(
      () => mockProcessLoginResultAction.execute(any()),
    ).thenAnswer((_) async => const Success(null));
  });
  /** Business Requirements (ViewModel, not View)
   * Group: Main Scenario
   * it must request a verification code for the specified email successfully
   * it must login with the email and code successfully
   * it must handle login that requires registration
   * Group: Error Handling
   * it must handle errors when requesting verification code fails
   * it must handle errors when logging in with email and code fails
   */

  group("Main Scenario", () {
    test(
      "it must request a verification code for the specified email successfully",
      () async {
        // Act
        viewModel.requestCodeCommand.execute(email);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.requestCodeCommand.value, isNotNull);
        expect(viewModel.requestCodeCommand.value!.isSuccess(), true);
        expect(viewModel.requestCodeCommand.value!.tryGetSuccess(), email);

        verify(() => mockAuthRepository.requestEmailCode(email)).called(1);
      },
    );

    test("it must login with the email and code successfully", () async {
      // Arrange: should have e-mail set
      viewModel.requestCodeCommand.execute(email);
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      viewModel.verifyCodeCommand.execute(serverCode);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(viewModel.verifyCodeCommand.value, isNotNull);
      expect(viewModel.verifyCodeCommand.value!.isSuccess(), true);
      expect(
        viewModel.verifyCodeCommand.value!.tryGetSuccess(),
        serverSuccessLogin,
      );

      verify(
        () => mockAuthRepository.loginWithEmail(email, serverCode),
      ).called(1);
      verify(
        () => mockProcessLoginResultAction.execute(serverSuccessLogin),
      ).called(1);
    });

    test("it must handle login that requires registration", () async {
      // Arrange: should have e-mail set
      viewModel.requestCodeCommand.execute(email);
      await Future.delayed(const Duration(milliseconds: 100));

      // Arrange: unregistered user
      when(
        () => mockAuthRepository.loginWithEmail(email, serverCode),
      ).thenAnswer((_) async => const Success(serverNeedsRegister));

      // Act
      viewModel.verifyCodeCommand.execute(serverCode);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(viewModel.verifyCodeCommand.value, isNotNull);
      expect(viewModel.verifyCodeCommand.value!.isSuccess(), true);
      expect(
        viewModel.verifyCodeCommand.value!.tryGetSuccess(),
        serverNeedsRegister,
      );
      verify(
        () => mockProcessLoginResultAction.execute(serverNeedsRegister),
      ).called(1);
    });
  });

  group("Error Handling", () {
    test(
      "it must handle errors when requesting verification code fails",
      () async {
        // Arrange
        const String email = "test@example.com";
        when(
          () => mockAuthRepository.requestEmailCode(any()),
        ).thenAnswer((_) async => Error(Exception("Network error")));

        // Act
        viewModel.requestCodeCommand.execute(email);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.requestCodeCommand.value, isNotNull);
        expect(viewModel.requestCodeCommand.value!.isError(), true);
      },
    );

    test(
      "it must handle errors when logging in with email and code fails",
      () async {
        // Arrange: should have e-mail set
        viewModel.requestCodeCommand.execute(email);
        await Future.delayed(const Duration(milliseconds: 100));

        // Arrange: error on login
        when(
          () => mockAuthRepository.loginWithEmail(any(), serverCode),
        ).thenAnswer(
          (_) async => Error(EmailLoginIncorrectCodeException("Invalid code")),
        );

        // Act
        viewModel.verifyCodeCommand.execute(serverCode);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.verifyCodeCommand.value, isNotNull);
        expect(viewModel.verifyCodeCommand.value!.isError(), true);
        expect(
          viewModel.verifyCodeCommand.value!.tryGetError(),
          isA<EmailLoginIncorrectCodeException>(),
        );
      },
    );

    test(
      "it must handle errors when logging in with email and code fails",
      () async {
        // Arrange: should have e-mail set
        viewModel.requestCodeCommand.execute(email);
        await Future.delayed(const Duration(milliseconds: 100));

        // Arrange: error on login
        when(
          () => mockAuthRepository.loginWithEmail(any(), serverCode),
        ).thenAnswer(
          (_) async => Error(EmailLoginUnexpectedException("Unknown Error")),
        );

        // Act
        viewModel.verifyCodeCommand.execute(serverCode);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.verifyCodeCommand.value, isNotNull);
        expect(viewModel.verifyCodeCommand.value!.isError(), true);
        expect(
          viewModel.verifyCodeCommand.value!.tryGetError(),
          isA<EmailLoginUnexpectedException>(),
        );
      },
    );

    test(
      "it must handle errors when no e-mail is set for code verification",
      () async {
        // Act
        viewModel.verifyCodeCommand.execute(serverCode);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.verifyCodeCommand.value, isNotNull);
        expect(viewModel.verifyCodeCommand.value!.isError(), true);
      },
    );
  });
}
