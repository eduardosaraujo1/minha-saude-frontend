import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_edit_view_model.dart';
import 'package:minha_saude_frontend/app/ui/settings/widgets/edit/settings_edit_name.dart';
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
      fieldType: SettingsEditField.name,
      profileRepository: profileRepository,
    );

    view = MaterialApp(
      home: MockGoRouterProvider(
        goRouter: mockGoRouter,
        child: SettingsEditName(viewModelFactory: () => viewModel),
      ),
    );
  });

  testWidgets("displays name input field and save button", (tester) async {
    await tester.pumpWidget(view);
    await tester.pump(Duration(milliseconds: 100));

    expect(find.byKey(ValueKey('inputName')), findsOneWidget);
    expect(find.byKey(ValueKey('btnSave')), findsOneWidget);

    await tester.disposeWidget();
  });

  testWidgets("loads initial name value", (tester) async {
    await tester.pumpWidget(view);
    await tester.pump(Duration(milliseconds: 100));

    final nameField = find.byKey(ValueKey('inputName'));
    final textFormField = tester.widget<TextFormField>(nameField);

    expect(textFormField.controller?.text, "initialValue");

    await tester.disposeWidget();
  });

  testWidgets("calls updateName when valid name is submitted", (tester) async {
    await tester.pumpWidget(view);
    await tester.pump(Duration(milliseconds: 100));

    await tester.enterText(find.byKey(ValueKey('inputName')), "new name");
    await tester.tap(find.byKey(ValueKey('btnSave')));
    await tester.pumpAndSettle();

    verify(() => profileRepository.updateName("new name")).called(1);
    await tester.disposeWidget();
  });

  testWidgets(
    "does not call updateName when empty name is submitted",
    (tester) async {
      await tester.pumpWidget(view);
      await tester.pump(Duration(milliseconds: 100));

      await tester.enterText(find.byKey(ValueKey('inputName')), "");
      await tester.tap(find.byKey(ValueKey('btnSave')));
      await tester.pumpAndSettle();

      verifyNever(() => profileRepository.updateName(any()));
      await tester.disposeWidget();
    },
    timeout: Timeout(Duration(seconds: 10)),
  );
}
