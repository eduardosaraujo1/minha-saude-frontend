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

import '../../../../testing/mocks/actions/mock_delete_user_action.dart';
import '../../../../testing/mocks/mock_go_router.dart';
import '../../../../testing/mocks/actions/mock_logout_action.dart';
import '../../../../testing/mocks/repositories/mock_profile_repository.dart';
import '../../../../testing/mocks/actions/mock_request_export_action.dart';
import '../../../../testing/models/profile.dart';
import '../../../../testing/utils/command_it.dart';
import '../../../../testing/utils/format.dart';

class MockThemeController extends Mock implements ThemeController {}

void main() {
  late MockGoRouter mockGoRouter;
  late Widget view;
  late SettingsViewModel viewModel;
  late MockLogoutAction mockLogoutAction;
  late MockDeleteUserAction mockDeleteUserAction;
  late MockRequestExportAction mockRequestExportAction;
  late Profile mockProfile;
  late ProfileRepository profileRepository;

  setUp(() {
    mockGoRouter = MockGoRouter();
    when(() => mockGoRouter.pop()).thenReturn(null);
    when(() => mockGoRouter.canPop()).thenReturn(false);

    mockLogoutAction = MockLogoutAction();
    mockDeleteUserAction = MockDeleteUserAction();
    mockRequestExportAction = MockRequestExportAction();
    profileRepository = MockProfileRepository();
    mockProfile = randomProfile();

    // Set up mock return values
    when(
      () => profileRepository.getProfile(
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Success(mockProfile));
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

    view = MaterialApp(
      home: MockGoRouterProvider(
        goRouter: mockGoRouter,
        child: SettingsTabView(() => viewModel),
      ),
    );
  });

  group("General Settings Tab", () {
    testWidgets(
      "can see edit buttons, export button and dark theme button after load",
      (tester) async {
        await tester.pumpWidget(view);
        await tester.pump(Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Should be on general tab by default
        expect(find.byKey(ValueKey('btnEditName')), findsOneWidget);
        expect(find.byKey(ValueKey('btnEditBirthdate')), findsOneWidget);
        expect(find.byKey(ValueKey('btnEditPhone')), findsOneWidget);
        expect(find.byKey(ValueKey('btnExportData')), findsOneWidget);
        expect(find.byKey(ValueKey('darkThemeSwitch')), findsOneWidget);

        await waitForDispose(tester);
      },
    );

    testWidgets("can see user information after loading", (tester) async {
      // Load widget
      await tester.pumpWidget(view);
      await tester.pump(Duration(milliseconds: 500));

      // Trigger the loadProfile command
      viewModel.loadProfile.execute();

      // Pump 100 ms to allow async operations to complete
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Find text widgets with profile data
      var profile = mockProfile;
      var formattedCpf =
          "${profile.cpf.substring(0, 3)}.${profile.cpf.substring(3, 6)}.${profile.cpf.substring(6, 9)}-${profile.cpf.substring(9)}";
      expect(find.text(profile.nome), findsOneWidget);
      expect(find.text(profile.email), findsOneWidget);
      expect(find.text(formattedCpf), findsOneWidget);
      expect(find.text(profile.telefone), findsOneWidget);
      expect(find.text(formatDate(profile.dataNascimento)), findsOneWidget);

      await waitForDispose(tester);
    });
  });

  group("Account Tab", () {
    testWidgets(
      "if on account tab can see signout and delete account buttons",
      (tester) async {
        await tester.pumpWidget(view);
        await tester.pump(Duration(milliseconds: 500));

        // Navigate to account tab (index 1)
        final tabBar = find.byType(TabBar);
        expect(tabBar, findsOneWidget);

        await tester.tap(find.text('Conta'));
        await tester.pumpAndSettle();

        expect(find.byKey(ValueKey('btnLogout')), findsOneWidget);
        expect(find.byKey(ValueKey('btnDeleteAccount')), findsOneWidget);
        await waitForDispose(tester);
      },
    );
  });

  group("Fragile Tests - May be removed when requirements change", () {
    testWidgets("when click on edit name button, navigates to edit name page", (
      tester,
    ) async {
      when(() => mockGoRouter.go(any())).thenReturn(null);

      await tester.pumpWidget(view);
      await tester.pump(Duration(milliseconds: 500));

      await tester.tap(find.byKey(ValueKey('btnEditName')));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.go(Routes.editNome)).called(1);

      await waitForDispose(tester);
    });

    testWidgets(
      "when click on edit birthdate button, navigates to edit birthdate page",
      (tester) async {
        when(() => mockGoRouter.go(any())).thenReturn(null);

        await tester.pumpWidget(view);
        await tester.pump(Duration(milliseconds: 500));

        await tester.tap(find.byKey(ValueKey('btnEditBirthdate')));
        await tester.pumpAndSettle();

        verify(
          () => mockGoRouter.go('/configuracoes/edit/birthdate'),
        ).called(1);

        await waitForDispose(tester);
      },
    );

    testWidgets(
      "when click on edit phone button, navigates to edit phone page",
      (tester) async {
        when(() => mockGoRouter.go(any())).thenReturn(null);

        await tester.pumpWidget(view);
        await tester.pump(Duration(milliseconds: 500));

        await tester.tap(find.byKey(ValueKey('btnEditPhone')));
        await tester.pumpAndSettle();

        verify(() => mockGoRouter.go('/configuracoes/edit/telefone')).called(1);
        await waitForDispose(tester);
      },
    );
    testWidgets(
      "when click on export documents button, calls export documents action",
      (tester) async {
        await tester.pumpWidget(view);
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
        await waitForDispose(tester);
      },
    );

    testWidgets("when click on signout button, calls logout action", (
      tester,
    ) async {
      await tester.pumpWidget(view);
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
      await waitForDispose(tester);
    });

    testWidgets(
      "when click on delete account button, calls delete account action",
      (tester) async {
        await tester.pumpWidget(view);
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
        await waitForDispose(tester);
      },
    );
  });
}
