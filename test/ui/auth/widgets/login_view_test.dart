import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/login_with_google.dart';
import 'package:minha_saude_frontend/app/routing/routes.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/login_view_model.dart';
import 'package:minha_saude_frontend/app/ui/auth/widgets/login_view.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../testing/app.dart';
import '../../../../testing/mocks/mock_go_router.dart';
import '../../../../testing/utils/command_it.dart';
import '../view_model/login_view_model_test.dart';

void main() {
  // UNIT
  // can find google login and email login buttons
  // INTEGRATION
  // navigates to TOS screen after login if unregistered
  // navigates to main screen after login if registered

  late Widget view;
  late LoginViewModel viewModel;
  late LoginWithGoogle loginWithGoogleAction;
  late MockGoRouter mockGoRouter;
  setUp(() {
    mockGoRouter = MockGoRouter();
    when(() => mockGoRouter.go(any())).thenReturn(null);
    when(() => mockGoRouter.pop()).thenReturn(null);
    when(() => mockGoRouter.canPop()).thenReturn(false);

    loginWithGoogleAction = MockLoginWithGoogle();

    when(
      () => loginWithGoogleAction.execute(),
    ).thenAnswer((_) async => Success(RedirectResponse.toRegister));

    viewModel = LoginViewModel(loginWithGoogleAction);
    view = testApp(
      mockGoRouter: mockGoRouter,
      Scaffold(body: LoginView(() => viewModel)),
    );
  });

  group("UNIT - UI Elements", () {
    testWidgets("it can find login buttons", (tester) async {
      await tester.pumpWidget(view);

      expect(find.byKey(const ValueKey('btnLoginGoogle')), findsOneWidget);
      expect(find.byKey(const ValueKey('btnLoginEmail')), findsOneWidget);

      await tester.disposeWidget();
    });
  });

  group("Submission Protection", () {
    setUp(() {
      when(() => loginWithGoogleAction.execute()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return const Success(RedirectResponse.toHome);
      });
    });

    testWidgets("it prevents duplicate submissions while processing", (
      tester,
    ) async {
      await tester.pumpWidget(view);

      // Tap login button twice rapidly
      await tester.tap(find.byKey(const ValueKey('btnLoginGoogle')));
      await tester.pump(); // Start first request

      await tester.tap(find.byKey(const ValueKey('btnLoginGoogle')));
      await tester.pump(); // Attempt second request

      // Wait for operations to complete
      await tester.pumpAndSettle();

      // Verify login was only called once (not twice)
      verify(() => loginWithGoogleAction.execute()).called(1);

      await tester.disposeWidget();
    });
  });

  group("Registered User Flow", () {
    setUp(() {
      when(
        () => loginWithGoogleAction.execute(),
      ).thenAnswer((_) async => const Success(RedirectResponse.toHome));
    });

    testWidgets("it calls login action when Google button is tapped", (
      tester,
    ) async {
      await tester.pumpWidget(view);

      await tester.tap(find.byKey(const ValueKey('btnLoginGoogle')));
      await tester.pump(Duration(milliseconds: 100));

      verify(() => loginWithGoogleAction.execute()).called(1);

      await tester.disposeWidget();
    });

    testWidgets("it navigates to documents screen after successful login", (
      tester,
    ) async {
      await tester.pumpWidget(view);
      await tester.tap(find.byKey(const ValueKey('btnLoginGoogle')));
      await tester.pumpAndSettle();
      verify(() => mockGoRouter.go(Routes.home)).called(1);

      await tester.disposeWidget();
    });
  });

  group("Unregistered User Flow", () {
    setUp(() {
      when(
        () => loginWithGoogleAction.execute(),
      ).thenAnswer((_) async => const Success(RedirectResponse.toRegister));
    });

    testWidgets("it calls login action when Google button is tapped", (
      tester,
    ) async {
      await tester.pumpWidget(view);

      await tester.tap(find.byKey(const ValueKey('btnLoginGoogle')));
      await tester.pump(Duration(milliseconds: 100));

      verify(() => loginWithGoogleAction.execute()).called(1);

      await tester.disposeWidget();
    });

    testWidgets("it navigates to tos screen after successful login", (
      tester,
    ) async {
      await tester.pumpWidget(view);
      await tester.tap(find.byKey(const ValueKey('btnLoginGoogle')));
      await tester.pumpAndSettle(Duration(milliseconds: 500));

      verify(() => mockGoRouter.go(Routes.tos)).called(1);

      await tester.disposeWidget();
    });
  });
}
