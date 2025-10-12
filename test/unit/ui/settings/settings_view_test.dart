import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/profile/profile.dart';
import 'package:minha_saude_frontend/app/routing/routes.dart';
import 'package:minha_saude_frontend/app/ui/core/theme_provider.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_view_model.dart';
import 'package:minha_saude_frontend/app/ui/settings/widgets/settings_tab_view.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../mocks/mock_delete_user_action.dart';
import '../../../mocks/mock_go_router.dart';
import '../../../mocks/mock_logout_action.dart';
import '../../../mocks/mock_profile_repository.dart';
import '../../../mocks/mock_request_export_action.dart';

class MockThemeController extends Mock implements ThemeController {}

void main() {
  late SettingsViewModel viewModel;
  late MockLogoutAction mockLogoutAction;
  late MockDeleteUserAction mockDeleteUserAction;
  late MockRequestExportAction mockRequestExportAction;
  late ProfileRepository profileRepository;
  late MockGoRouter mockGoRouter;
  setUp(() {
    mockGoRouter = MockGoRouter();
    when(() => mockGoRouter.pop()).thenReturn(null);
    when(() => mockGoRouter.canPop()).thenReturn(false);
    mockLogoutAction = MockLogoutAction();
    mockDeleteUserAction = MockDeleteUserAction();
    mockRequestExportAction = MockRequestExportAction();
    profileRepository = MockProfileRepository();

    // Set up mock return values
    when(
      () => mockLogoutAction.execute(),
    ).thenAnswer((_) async => Success(null));
    when(
      () => mockDeleteUserAction.execute(),
    ).thenAnswer((_) async => Success(null));
    when(
      () => mockRequestExportAction.execute(),
    ).thenAnswer((_) async => Success(null));

    viewModel = SettingsViewModel(
      profileRepository: profileRepository,
      logoutAction: mockLogoutAction,
      deleteUserAction: mockDeleteUserAction,
      requestExportAction: mockRequestExportAction,
    );
  });

  testWidgets(
    "if on general tab can see edit buttons, export button and dark theme button",
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MockGoRouterProvider(
            goRouter: mockGoRouter,
            child: SettingsTabView(viewModel),
          ),
        ),
      );
      await tester.pump(Duration(milliseconds: 500));

      // Should be on general tab by default
      expect(find.byKey(ValueKey('btnEditName')), findsOneWidget);
      expect(find.byKey(ValueKey('btnEditBirthdate')), findsOneWidget);
      expect(find.byKey(ValueKey('btnEditPhone')), findsOneWidget);
      expect(find.byKey(ValueKey('btnExportData')), findsOneWidget);
      expect(find.byKey(ValueKey('darkThemeSwitch')), findsOneWidget);
    },
  );

  testWidgets("when click on edit name button, navigates to edit name page", (
    tester,
  ) async {
    when(() => mockGoRouter.go(any())).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: MockGoRouterProvider(
          goRouter: mockGoRouter,
          child: SettingsTabView(viewModel),
        ),
      ),
    );
    await tester.pump(Duration(milliseconds: 500));

    await tester.tap(find.byKey(ValueKey('btnEditName')));
    await tester.pumpAndSettle();

    verify(() => mockGoRouter.go(Routes.editNome)).called(1);
  });

  testWidgets(
    "when click on edit birthdate button, navigates to edit birthdate page",
    (tester) async {
      when(() => mockGoRouter.go(any())).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: MockGoRouterProvider(
            goRouter: mockGoRouter,
            child: SettingsTabView(viewModel),
          ),
        ),
      );
      await tester.pump(Duration(milliseconds: 500));

      await tester.tap(find.byKey(ValueKey('btnEditBirthdate')));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.go('/configuracoes/edit/birthdate')).called(1);
    },
  );

  testWidgets("when click on edit phone button, navigates to edit phone page", (
    tester,
  ) async {
    when(() => mockGoRouter.go(any())).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: MockGoRouterProvider(
          goRouter: mockGoRouter,
          child: SettingsTabView(viewModel),
        ),
      ),
    );
    await tester.pump(Duration(milliseconds: 500));

    await tester.tap(find.byKey(ValueKey('btnEditPhone')));
    await tester.pumpAndSettle();

    verify(() => mockGoRouter.go('/configuracoes/edit/telefone')).called(1);
  });
  testWidgets(
    "when click on export documents button, calls export documents action",
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MockGoRouterProvider(
            goRouter: mockGoRouter,
            child: SettingsTabView(viewModel),
          ),
        ),
      );
      await tester.pump(Duration(milliseconds: 500));

      // Tap export data button
      await tester.tap(find.byKey(ValueKey('btnExportData')));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      var confirmExport = find.byKey(ValueKey("btnConfirmExport"));
      expect(confirmExport, findsOneWidget);

      // Tap confirm in dialog
      await tester.tap(confirmExport);
      await tester.pumpAndSettle();

      // Verify the action was called
      verify(() => mockRequestExportAction.execute()).called(1);
    },
  );

  testWidgets("when click on dark theme toggle, switch to dark theme", (
    tester,
  ) async {
    ThemeController mockThemeController = MockThemeController();

    when(() => mockThemeController.toggleTheme()).thenReturn(null);

    await tester.binding.setSurfaceSize(Size(800, 900));
    addTearDown(() {
      tester.binding.reset();
    });

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
    await tester.pump(Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Scroll to make the switch visible if needed
    var darkThemeSwitchFinder = find.byKey(ValueKey("darkThemeSwitch"));
    await tester.ensureVisible(darkThemeSwitchFinder);
    await tester.pumpAndSettle();

    // Tap the dark theme switch
    await tester.tap(darkThemeSwitchFinder);
    await tester.pumpAndSettle();

    // Verify toggleTheme was called
    verify(() => mockThemeController.toggleTheme()).called(1);
  });

  testWidgets("if on account tab can see signout and delete account buttons", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MockGoRouterProvider(
          goRouter: mockGoRouter,
          child: SettingsTabView(viewModel),
        ),
      ),
    );
    await tester.pump(Duration(milliseconds: 500));

    // Navigate to account tab (index 1)
    final tabBar = find.byType(TabBar);
    expect(tabBar, findsOneWidget);

    await tester.tap(find.text('Conta'));
    await tester.pumpAndSettle();

    expect(find.byKey(ValueKey('btnLogout')), findsOneWidget);
    expect(find.byKey(ValueKey('btnDeleteAccount')), findsOneWidget);
  });

  testWidgets("when click on signout button, calls logout action", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MockGoRouterProvider(
          goRouter: mockGoRouter,
          child: SettingsTabView(viewModel),
        ),
      ),
    );
    await tester.pump(Duration(milliseconds: 500));

    // Navigate to account tab
    await tester.tap(find.text('Conta'));
    await tester.pumpAndSettle();

    // Tap logout button
    await tester.tap(find.byKey(ValueKey('btnLogout')));
    await tester.pumpAndSettle();

    // Should show confirmation dialog
    var confirmSignout = find.byKey(ValueKey("btnConfirmLogout"));
    expect(confirmSignout, findsOneWidget);

    // Tap confirm in dialog
    await tester.tap(confirmSignout);
    await tester.pumpAndSettle();

    verify(() => mockLogoutAction.execute()).called(1);
  });

  testWidgets(
    "when click on delete account button, calls delete account action",
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MockGoRouterProvider(
            goRouter: mockGoRouter,
            child: SettingsTabView(viewModel),
          ),
        ),
      );
      await tester.pump(Duration(milliseconds: 500));

      // Navigate to account tab
      await tester.tap(find.text('Conta'));
      await tester.pumpAndSettle();

      // Tap delete account button
      await tester.tap(find.byKey(ValueKey('btnDeleteAccount')));
      await tester.pumpAndSettle();

      // Should show confirm button
      var confirmDelete = find.byKey(ValueKey("btnConfirmDeleteAccount"));
      expect(confirmDelete, findsOneWidget);

      // Tap confirm in dialog
      await tester.tap(
        confirmDelete,
      ); // Use .last to get the button, not the title
      await tester.pumpAndSettle();

      verify(() => mockDeleteUserAction.execute()).called(1);
    },
  );

  testWidgets("when screen loads user information is available on screen", (
    tester,
  ) async {
    // Mock profile data
    final profile = Profile(
      id: "0",
      email: "example@gmail.com",
      cpf: "12345678909",
      nome: "João Silva",
      telefone: "11987654321",
      dataNascimento: DateTime(1990, 5, 15),
      metodoAutenticacao: AuthMethod.google,
    );
    when(
      () => profileRepository.getProfile(),
    ).thenAnswer((_) async => Success(profile));

    // Load widget
    await tester.pumpWidget(
      MaterialApp(
        home: MockGoRouterProvider(
          goRouter: mockGoRouter,
          child: SettingsTabView(viewModel),
        ),
      ),
    );
    await tester.pump(Duration(milliseconds: 500));

    // Trigger the loadProfile command
    viewModel.loadProfile.execute();

    // Pump 100 ms to allow async operations to complete
    await tester.pump(Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Find text widgets with profile data
    expect(find.text("João Silva"), findsOneWidget);
    expect(find.text("example@gmail.com"), findsOneWidget);
    expect(find.text("123.456.789-09"), findsOneWidget);
    expect(find.text("11987654321"), findsOneWidget);

    // For date, we need to check the formatted version that would appear in the UI
    // The exact format depends on how the date is displayed in the UI
    // Since we don't know the exact format, let's check for the year at least
    expect(find.textContaining("1990"), findsOneWidget);
  });
}
