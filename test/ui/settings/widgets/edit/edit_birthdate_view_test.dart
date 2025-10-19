import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_edit_view_model.dart';
import 'package:minha_saude_frontend/app/ui/settings/widgets/edit/settings_edit_birthdate.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../../testing/mocks/mock_go_router.dart';
import '../../../../../testing/mocks/repositories/mock_profile_repository.dart';
import '../../../../../testing/models/profile.dart';
import '../../../../../testing/utils/command_it.dart';

void main() {
  late ProfileRepository profileRepository;
  late MockGoRouter mockGoRouter;
  late SettingsEditViewModel viewModel;
  late Widget view;

  setUp(() {
    mockGoRouter = MockGoRouter();
    profileRepository = MockProfileRepository();

    when(() => mockGoRouter.pop()).thenReturn(null);
    when(() => mockGoRouter.canPop()).thenReturn(true);

    when(() => profileRepository.getProfile()).thenAnswer(
      (_) async => Success(
        arbitraryProfile().copyWith(
          nome: "initialValue",
          telefone: "initialValue",
          dataNascimento: DateTime(2020, 1, 1),
        ),
      ),
    );

    viewModel = SettingsEditViewModel(
      fieldType: SettingsEditField.birthdate,
      profileRepository: profileRepository,
    );

    view = MaterialApp(
      home: MockGoRouterProvider(
        goRouter: mockGoRouter,
        child: SettingsEditBirthdate(viewModelFactory: () => viewModel),
      ),
    );
  });

  testWidgets("displays birthdate input field and save button", (tester) async {
    await tester.pumpWidget(view);
    await tester.pump(Duration(milliseconds: 100));

    expect(find.byKey(ValueKey('inputBirthdate')), findsOneWidget);
    expect(find.byKey(ValueKey('btnSave')), findsOneWidget);

    await tester.disposeWidget();
  });

  testWidgets("loads initial birthdate value", (tester) async {
    await tester.pumpWidget(view);
    await tester.pump(Duration(milliseconds: 100));

    final birthdateField = find.byKey(ValueKey('inputBirthdate'));
    final textFormField = tester.widget<TextFormField>(birthdateField);

    expect(textFormField.controller?.text, "01/01/2020");
    await tester.disposeWidget();
  });

  testWidgets("calls updateBirthdate when valid date is submitted", (
    tester,
  ) async {
    await tester.pumpWidget(view);
    await tester.pump(Duration(milliseconds: 100));

    // Override controller directly for date picker
    final formFinder = find.byKey(ValueKey('inputBirthdate'));
    final form = tester.widget(formFinder) as TextFormField;
    form.controller?.text = "01/01/2025";
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey('btnSave')));
    await tester.pumpAndSettle();

    verify(
      () => profileRepository.updateBirthdate(DateTime(2025, 1, 1)),
    ).called(1);
    await tester.disposeWidget();
  });

  testWidgets(
    "does not call updateBirthdate when empty date is submitted",
    (tester) async {
      await tester.pumpWidget(view);
      await tester.pump(Duration(milliseconds: 100));

      final birthdateField = find.byKey(ValueKey('inputBirthdate'));
      final formField = tester.widget<TextFormField>(birthdateField);
      formField.controller?.text = "";
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('btnSave')));
      await tester.pumpAndSettle();

      verifyNever(() => profileRepository.updateBirthdate(any()));
      await tester.disposeWidget();
    },
    timeout: Timeout(Duration(seconds: 10)),
  );
}
