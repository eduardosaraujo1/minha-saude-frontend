import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/ui/core/theme_provider.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_view_model.dart';
import 'package:minha_saude_frontend/app/ui/settings/widgets/settings_tab_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks/mock_delete_user_action.dart';
import '../../../mocks/mock_go_router.dart';
import '../../../mocks/mock_logout_action.dart';

class MockThemeController extends Mock implements ThemeController {}

void main() {
  late SettingsViewModel viewModel;
  late MockLogoutAction mockLogoutAction;
  late MockDeleteUserAction mockDeleteUserAction;
  late MockGoRouter mockGoRouter;
  setUp(() {
    mockGoRouter = MockGoRouter();
    mockLogoutAction = MockLogoutAction();
    mockDeleteUserAction = MockDeleteUserAction();
    viewModel = SettingsViewModel(
      logoutAction: mockLogoutAction,
      deleteUserAction: mockDeleteUserAction,
    );
  });
  testWidgets(
    "if on general tab can see edit buttons, export button and dark theme button",
    (tester) async {},
  );

  testWidgets(
    "when click on edit name button, navigates to edit name page",
    (tester) async {},
  );

  testWidgets(
    "when click on edit birthdate button, navigates to edit birthdate page",
    (tester) async {},
  );

  testWidgets(
    "when click on edit phone button, navigates to edit phone page",
    (tester) async {},
  );
  testWidgets(
    "when click on export documents button, calls export documents action",
    (tester) async {},
  );

  testWidgets("when click on dark theme toggle, switch to dark theme", (
    tester,
  ) async {
    ThemeController mockThemeController = MockThemeController();

    when(() => mockThemeController.toggleTheme()).thenReturn(null);
    when(() => mockGoRouter.canPop()).thenReturn(false);

    // Set a larger surface size to accommodate the scrollable content
    // tester.view.physicalSize = Size(800, 1200);
    // tester.view.devicePixelRatio = 1.0;
    // addTearDown(() {
    //   tester.view.resetPhysicalSize();
    //   tester.view.resetDevicePixelRatio();
    // });

    await tester.pumpWidget(
      MaterialApp(
        home: MockGoRouterProvider(
          goRouter: mockGoRouter,
          child: ThemeProvider(
            controller: mockThemeController,
            child: SettingsTabView(viewModel),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Scroll to make the switch visible if needed
    var darkThemeSwitchFinder = find.byKey(ValueKey("darkThemeSwitch"));
    await tester.scrollUntilVisible(
      darkThemeSwitchFinder,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(darkThemeSwitchFinder);
    await tester.pumpAndSettle();

    // Tap the dark theme switch
    await tester.tap(darkThemeSwitchFinder);
    await tester.pumpAndSettle();

    // Verify toggleTheme was called
    verify(() => mockThemeController.toggleTheme()).called(1);
  });

  testWidgets(
    "if on account tab can see signout and delete account buttons",
    (tester) async {},
  );

  testWidgets(
    "when click on signout button, calls logout action",
    (tester) async {},
  );

  testWidgets(
    "when click on delete account button, calls delete account action",
    (tester) async {},
  );
}
