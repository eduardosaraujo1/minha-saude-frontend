import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_edit_view_model.dart';
import 'package:minha_saude_frontend/app/ui/settings/widgets/edit/settings_edit_phone.dart';
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
      fieldType: SettingsEditField.phone,
      profileRepository: profileRepository,
    );

    view = MaterialApp(
      home: MockGoRouterProvider(
        goRouter: mockGoRouter,
        child: SettingsEditPhone(viewModelFactory: () => viewModel),
      ),
    );
  });

  testWidgets("displays phone input field and save button", (tester) async {
    await tester.pumpWidget(view);
    await tester.pump(Duration(milliseconds: 100));

    expect(find.byKey(ValueKey('inputPhone')), findsOneWidget);
    expect(find.byKey(ValueKey('btnSave')), findsOneWidget);

    await waitForDispose(tester);
  });

  testWidgets("loads initial phone value", (tester) async {
    await tester.pumpWidget(view);
    await tester.pump(Duration(milliseconds: 100));

    final phoneField = find.byKey(ValueKey('inputPhone'));
    final textFormField = tester.widget<TextFormField>(phoneField);

    expect(textFormField.controller?.text, "initialValue");

    await waitForDispose(tester);
  });

  testWidgets("calls updatePhone when valid phone is submitted", (
    tester,
  ) async {
    await tester.pumpWidget(view);
    await tester.pump(Duration(milliseconds: 100));

    await tester.enterText(find.byKey(ValueKey('inputPhone')), "11987654321");
    await tester.tap(find.byKey(ValueKey('btnSave')));
    await tester.pumpAndSettle();

    verify(() => profileRepository.updatePhone("11987654321")).called(1);

    await waitForDispose(tester);
  });

  testWidgets(
    "does not call updatePhone when empty phone is submitted",
    (tester) async {
      await tester.pumpWidget(view);
      await tester.pump(Duration(milliseconds: 100));

      await tester.enterText(find.byKey(ValueKey('inputPhone')), "");
      await tester.tap(find.byKey(ValueKey('btnSave')));
      await tester.pumpAndSettle();

      verifyNever(() => profileRepository.updatePhone(any()));

      await waitForDispose(tester);
    },
    timeout: Timeout(Duration(seconds: 10)),
  );
}
