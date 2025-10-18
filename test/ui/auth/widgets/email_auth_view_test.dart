import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/email_auth_view_model.dart';
import 'package:minha_saude_frontend/app/ui/auth/widgets/email/email_auth_view.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/src/result.dart';

import '../../../../testing/app.dart';
import '../../../../testing/mocks/mock_go_router.dart';
import '../../../../testing/mocks/repositories/mock_auth_repository.dart';
import '../../../../testing/utils/command_it.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Widget view;
  late EmailAuthViewModel viewModel;
  late MockAuthRepository mockAuthRepository;

  const String email = "test@example.com";
  const String code = "123456";
  const String serverSessionToken = "valid-session-token-123";

  setUp(() {
    // Mock ViewModel Commands
    mockAuthRepository = MockAuthRepository();

    // Arrange: successful sending of email verification code
    when(
      () => mockAuthRepository.requestEmailCode(any(that: isNot(email))),
    ).thenAnswer((_) async => Error(Exception("Invalid email format")));
    when(
      () => mockAuthRepository.requestEmailCode(email),
    ).thenAnswer((_) async => const Success(null));

    // Arrange: successful login with email on correct code
    when(
      () => mockAuthRepository.loginWithEmail(email, any()),
    ).thenAnswer((_) async => Error(Exception("Invalid verification code")));
    when(() => mockAuthRepository.loginWithEmail(email, code)).thenAnswer(
      (_) async => const Success(
        LoginResult.successful(sessionToken: serverSessionToken),
      ),
    );
    // Note: NeedsRegistration case could be added, but is not currently necessary
    // as it concerns only the ViewModel (View would only change navigation, which is not tested)

    viewModel = EmailAuthViewModel(authRepository: mockAuthRepository);

    view = testApp(
      mockGoRouter: MockGoRouter(),
      Scaffold(body: EmailAuthView(viewModelFactory: () => viewModel)),
    );
  });
  /** Business Requirements (note: showing errors is hard to test and brittle, so assert that the repository methods are not called)
   * Group: Email Input Screen
   * it should have a text field for email input and a button to request code
   * it should request a verification code when a valid email is provided
   * it should not request a code with invalid email format
   * Group: Code Confirmation Screen
   * (obs: setup viewModel to be on Code Confirmation Screen)
   * it should have a text field for code input and a button to confirm code
   * it should attempt login when a valid code is provided
   * it should not submit when invalid code is provided
   * smoke: should not throw when incorrect code is provided
   */
  group("Email Input Screen", () {
    testWidgets(
      "it should have a text field for email input and a button to request code",
      (tester) async {
        // Arrange
        await tester.pumpWidget(view);

        // Assert: has email input field
        expect(find.byKey(const ValueKey('inputEmail')), findsOneWidget);

        // Assert: has request code button
        expect(find.byKey(const ValueKey('btnRequestCode')), findsOneWidget);

        await tester.disposeWidget();
      },
    );
    testWidgets(
      "it should request a verification code when a valid email is provided",
      (tester) async {
        await tester.pumpWidget(view);

        await tester.enterText(find.byKey(const ValueKey('inputEmail')), email);
        await tester.tap(find.byKey(const ValueKey('btnRequestCode')));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        verify(() => mockAuthRepository.requestEmailCode(email)).called(1);
        await tester.disposeWidget();
      },
    );
    testWidgets("it should not request a code with invalid email format", (
      tester,
    ) async {
      const String invalidEmail = "tes";

      // Act
      await tester.pumpWidget(view);
      await tester.enterText(
        find.byKey(const ValueKey('inputEmail')),
        invalidEmail,
      );
      await tester.tap(find.byKey(const ValueKey('btnRequestCode')));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Assert
      verifyNever(() => mockAuthRepository.requestEmailCode(any()));
      await tester.disposeWidget();
    });
  });
  group("Code Confirmation Screen", () {
    Future<void> setupCodeConfirmationScreen(WidgetTester tester) async {
      await tester.pumpWidget(view);

      final emailField = find.byKey(const ValueKey('inputEmail'));
      final requestCodeButton = find.byKey(const ValueKey('btnRequestCode'));

      await tester.enterText(emailField, email);
      await tester.pump();
      await tester.tap(requestCodeButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    }

    testWidgets(
      "it should have a text field for code input, a button for resend, and a button to confirm code",
      (tester) async {
        await setupCodeConfirmationScreen(tester);

        // Assert: has code input field
        expect(find.byKey(const ValueKey('inputCode')), findsOneWidget);

        // Assert: has resend code button
        expect(find.byKey(const ValueKey('btnResendCode')), findsOneWidget);

        // Assert: has confirm code button
        expect(find.byKey(const ValueKey('btnConfirmCode')), findsOneWidget);
        await tester.disposeWidget();
      },
    );
    testWidgets("it should attempt login when a valid code is provided", (
      tester,
    ) async {
      await setupCodeConfirmationScreen(tester);

      // Act
      await tester.enterText(find.byKey(const ValueKey('inputCode')), code);
      await tester.tap(find.byKey(const ValueKey('btnConfirmCode')));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Assert
      verify(() => mockAuthRepository.loginWithEmail(email, code)).called(1);
      await tester.disposeWidget();
    });
    testWidgets("it should not submit when invalid code is provided", (
      tester,
    ) async {
      await setupCodeConfirmationScreen(tester);

      const String invalidCode = "0000"; // (not 6 digits)

      // Act
      await tester.enterText(
        find.byKey(const ValueKey('inputCode')),
        invalidCode,
      );
      await tester.tap(find.byKey(const ValueKey('btnConfirmCode')));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Assert
      verifyNever(() => mockAuthRepository.loginWithEmail(any(), any()));
      await tester.disposeWidget();
    });
    testWidgets("smoke: should not throw when incorrect code is provided", (
      tester,
    ) async {
      await setupCodeConfirmationScreen(tester);

      const String wrongCode = "999999"; // (6 digits, but incorrect)

      // Act
      await tester.enterText(
        find.byKey(const ValueKey('inputCode')),
        wrongCode,
      );
      await tester.tap(find.byKey(const ValueKey('btnConfirmCode')));

      // Assert: if it throws then it'll fail the test
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      verify(
        () => mockAuthRepository.loginWithEmail(email, wrongCode),
      ).called(1);
      await tester.disposeWidget();
    });
  });
}
