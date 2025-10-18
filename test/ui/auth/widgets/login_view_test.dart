import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/login_view_model.dart';
import 'package:minha_saude_frontend/app/ui/auth/widgets/login_view.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../testing/app.dart';
import '../../../../testing/mocks/mock_go_router.dart';
import '../../../../testing/mocks/repositories/mock_auth_repository.dart';
import '../../../../testing/utils/command_it.dart';
import '../view_model/login_view_model_test.dart';

void main() {
  late MockProcessLoginResult mockProcessLoginResult;
  late MockAuthRepository mockAuthRepository;
  late MockGoRouter mockGoRouter;
  late Widget view;
  late LoginViewModel viewModel;

  const SuccessfulLoginResult mockSuccessResponse = SuccessfulLoginResult(
    sessionToken: "mock_session_token",
  );

  setUp(() {
    mockGoRouter = MockGoRouter();
    when(() => mockGoRouter.canPop()).thenReturn(false);
    when(() => mockGoRouter.go(any())).thenReturn(null);

    mockProcessLoginResult = MockProcessLoginResult();
    mockAuthRepository = MockAuthRepository();

    // Arrange: It successfully gets Google server token
    when(
      () => mockAuthRepository.getGoogleServerToken(),
    ).thenAnswer((_) async => const Success("valid-google-server-token-123"));

    // Arrange: It successfully logs in with Google
    when(
      () => mockAuthRepository.loginWithGoogle(any()),
    ).thenAnswer((_) async => const Success(mockSuccessResponse));

    // Arrange: it successfully stores token
    when(
      () => mockProcessLoginResult.execute(any()),
    ).thenAnswer((_) async => const Success(null));

    viewModel = LoginViewModel(
      authRepository: mockAuthRepository,
      processLoginAction: mockProcessLoginResult,
    );
    view = testApp(
      mockGoRouter: mockGoRouter,
      Scaffold(body: LoginView(() => viewModel)),
    );
  });

  /** Business Requirements
   * It can find google login and email login buttons
   * It triggers google login on google button tap
   * It does not allow duplicate google login submissions
   */

  testWidgets("it can find google login and email login buttons", (
    tester,
  ) async {
    // Arrange
    await tester.pumpWidget(view);

    // Assert
    expect(find.byKey(const ValueKey('btnLoginGoogle')), findsOneWidget);
    expect(find.byKey(const ValueKey('btnLoginEmail')), findsOneWidget);

    await tester.disposeWidget();
  });

  testWidgets("it triggers google login on google button tap", (tester) async {
    // Arrange
    await tester.pumpWidget(view);

    // Act
    await tester.tap(find.byKey(const ValueKey('btnLoginGoogle')));
    await tester.pump(const Duration(milliseconds: 100));

    // Assert
    expect(viewModel.loginWithGoogle.value, isNotNull);
    expect(viewModel.loginWithGoogle.value!.isSuccess(), true);

    await tester.disposeWidget();
  });

  testWidgets("it does not allow duplicate google login submissions", (
    tester,
  ) async {
    // Arrange
    when(() => mockAuthRepository.loginWithGoogle(any())).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      return const Success(mockSuccessResponse);
    });

    await tester.pumpWidget(view);

    // Act: Tap login button twice rapidly
    await tester.tap(find.byKey(const ValueKey('btnLoginGoogle')));
    await tester.pump(); // Start first request

    await tester.tap(find.byKey(const ValueKey('btnLoginGoogle')));
    await tester.pump(); // Attempt second request

    // Wait for operations to complete
    await tester.pumpAndSettle();

    // Assert: Login was only called once (not twice)
    verify(() => mockAuthRepository.loginWithGoogle(any())).called(1);

    await tester.disposeWidget();
  });
}
