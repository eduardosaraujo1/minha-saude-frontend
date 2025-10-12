import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/profile/profile.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_edit_view_model.dart';
import 'package:minha_saude_frontend/app/ui/settings/widgets/edit/settings_edit_birthdate.dart';
import 'package:minha_saude_frontend/app/ui/settings/widgets/edit/settings_edit_name.dart';
import 'package:minha_saude_frontend/app/ui/settings/widgets/edit/settings_edit_phone.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../mocks/mock_go_router.dart';
import '../../../mocks/mock_profile_repository.dart';

void main() {
  late ProfileRepository profileRepository;
  late MockGoRouter mockGoRouter;
  late SettingsEditViewModel viewModel;
  setUp(() {
    mockGoRouter = MockGoRouter();
    when(() => mockGoRouter.pop()).thenReturn(null);
    when(() => mockGoRouter.canPop()).thenReturn(true);

    profileRepository = MockProfileRepository();
    when(() => profileRepository.getProfile()).thenAnswer(
      (_) async => Success(
        Profile(
          id: "0",
          email: "example@gmail.com",
          cpf: "12345678909",
          nome: "initialValue",
          telefone: "initialValue",
          dataNascimento: DateTime(2020, 1, 1),
          metodoAutenticacao: AuthMethod.google,
        ),
      ),
    );
  });

  // Name Edit Tests
  group("Name Edit Tests", () {
    setUp(() {
      viewModel = SettingsEditViewModel(
        fieldType: SettingsEditField.name,
        profileRepository: profileRepository,
      );
    });
    testWidgets("when click on cancel then pop navigation", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MockGoRouterProvider(
            goRouter: mockGoRouter,
            child: SettingsEditName(viewModel: viewModel),
          ),
        ),
      );

      await tester.tap(find.byKey(ValueKey('btnCancel')));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.pop()).called(1);
    });
    testWidgets("can find edit name field, confirm button and cancel button", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: (SettingsEditName(viewModel: viewModel))),
      );
      await tester.pump(
        Duration(milliseconds: 100),
      ); // Allow async load to complete

      expect(find.byKey(ValueKey('inputName')), findsOneWidget);
      expect(find.byKey(ValueKey('btnCancel')), findsOneWidget);
      expect(find.byKey(ValueKey('btnSave')), findsOneWidget);
    });

    testWidgets("when widget loads initial value is placed in text form", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: (SettingsEditName(viewModel: viewModel))),
      );
      await tester.pump(
        Duration(milliseconds: 100),
      ); // Allow async load to complete

      final nameField = find.byKey(ValueKey('inputName'));
      expect(nameField, findsOneWidget);

      var textFormField = tester.widget<TextFormField>(nameField);
      expect(textFormField.controller?.text, "initialValue");
    });

    testWidgets(
      "when new name is typed and confirm is pressed, then name edit is triggered",
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MockGoRouterProvider(
              goRouter: mockGoRouter,
              child: SettingsEditName(viewModel: viewModel),
            ),
          ),
        );
        await tester.pump(
          Duration(milliseconds: 100),
        ); // Allow async load to complete

        final nameField = find.byKey(ValueKey('inputName'));
        final btnSave = find.byKey(ValueKey('btnSave'));
        expect(nameField, findsOneWidget);

        // Clear the field first, then enter new text
        await tester.enterText(nameField, "new name");
        await tester.pumpAndSettle();

        await tester.tap(btnSave);
        await tester.pumpAndSettle();

        verify(
          () => viewModel.profileRepository.updateName("new name"),
        ).called(1);
      },
    );

    testWidgets(
      "when invalid name is typed and confirm is pressed, then name edit is not triggered",
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: (SettingsEditName(viewModel: viewModel))),
        );
        await tester.pump(
          Duration(milliseconds: 100),
        ); // Allow async load to complete

        final nameField = find.byKey(ValueKey('inputName'));
        final btnSave = find.byKey(ValueKey('btnSave'));
        expect(nameField, findsOneWidget);

        // Empty the existing content of the field
        await tester.enterText(nameField, "");
        await tester.pumpAndSettle();

        await tester.tap(btnSave);
        await tester.pumpAndSettle();

        verifyNever(() => viewModel.profileRepository.updateName(any()));
      },
    );
  });

  // Birthdate Edit Tests
  group("Birthdate Edit Tests", () {
    setUp(() {
      viewModel = SettingsEditViewModel(
        fieldType: SettingsEditField.birthdate,
        profileRepository: profileRepository,
      );
    });
    testWidgets("when click on cancel then pop navigation", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MockGoRouterProvider(
            goRouter: mockGoRouter,
            child: SettingsEditBirthdate(viewModel: viewModel),
          ),
        ),
      );

      await tester.tap(find.byKey(ValueKey('btnCancel')));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.pop()).called(1);
    });

    testWidgets(
      "can find edit birthdate field, confirm button and cancel button",
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: (SettingsEditBirthdate(viewModel: viewModel))),
        );
        await tester.pump(
          Duration(milliseconds: 100),
        ); // Allow async load to complete

        expect(find.byKey(ValueKey('inputBirthdate')), findsOneWidget);
        expect(find.byKey(ValueKey('btnCancel')), findsOneWidget);
        expect(find.byKey(ValueKey('btnSave')), findsOneWidget);
      },
    );

    testWidgets("when widget loads initial value is placed in text form", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: (SettingsEditBirthdate(viewModel: viewModel))),
      );
      await tester.pump(
        Duration(milliseconds: 100),
      ); // Allow async load to complete

      final birthdateField = find.byKey(ValueKey('inputBirthdate'));
      expect(birthdateField, findsOneWidget);

      var textFormField = tester.widget<TextFormField>(birthdateField);
      expect(textFormField.controller?.text, "01/01/2020");
    });

    testWidgets(
      "when new birthdate is typed and confirm is pressed, then birthdate edit is triggered",
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MockGoRouterProvider(
              goRouter: mockGoRouter,
              child: SettingsEditBirthdate(viewModel: viewModel),
            ),
          ),
        );
        await tester.pump(
          Duration(milliseconds: 100),
        ); // Allow async load to complete

        final bdayField = find.byKey(ValueKey('inputBirthdate'));
        final btnSave = find.byKey(ValueKey('btnSave'));
        expect(bdayField, findsOneWidget);

        // Birthday uses datepicker internal implementation
        // Will override the controller directly
        final formFinder = find.byKey(ValueKey('inputBirthdate'));
        var form = tester.widget(formFinder) as TextFormField;
        form.controller?.text = "01/01/2025";
        await tester.pumpAndSettle();

        await tester.tap(btnSave);
        await tester.pumpAndSettle();

        verify(
          () =>
              viewModel.profileRepository.updateBirthdate(DateTime(2025, 1, 1)),
        ).called(1);
      },
    );

    testWidgets(
      "when invalid birthdate is typed and confirm is pressed, then birthdate edit is not triggered",
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: (SettingsEditBirthdate(viewModel: viewModel))),
        );
        await tester.pump(
          Duration(milliseconds: 100),
        ); // Allow async load to complete

        final birthdateField = find.byKey(ValueKey('inputBirthdate'));
        final btnSave = find.byKey(ValueKey('btnSave'));
        expect(birthdateField, findsOneWidget);

        // Empty the existing content of the field
        await tester.enterText(birthdateField, "");
        await tester.pumpAndSettle();

        await tester.tap(btnSave);
        await tester.pumpAndSettle();

        verifyNever(() => viewModel.profileRepository.updateBirthdate(any()));
      },
    );
  });
  group("Phone Edit Tests", () {
    setUp(() {
      viewModel = SettingsEditViewModel(
        fieldType: SettingsEditField.phone,
        profileRepository: profileRepository,
      );
    });
    testWidgets("when click on cancel then pop navigation", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MockGoRouterProvider(
            goRouter: mockGoRouter,
            child: SettingsEditPhone(viewModel: viewModel),
          ),
        ),
      );

      await tester.tap(find.byKey(ValueKey('btnCancel')));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.pop()).called(1);
    });

    testWidgets("can find edit phone field, confirm button and cancel button", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: (SettingsEditPhone(viewModel: viewModel))),
      );
      await tester.pump(
        Duration(milliseconds: 100),
      ); // Allow async load to complete

      expect(find.byKey(ValueKey('inputPhone')), findsOneWidget);
      expect(find.byKey(ValueKey('btnCancel')), findsOneWidget);
      expect(find.byKey(ValueKey('btnSave')), findsOneWidget);
    });

    testWidgets("when widget loads initial value is placed in text form", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: (SettingsEditPhone(viewModel: viewModel))),
      );
      await tester.pump(
        Duration(milliseconds: 100),
      ); // Allow async load to complete

      final phoneField = find.byKey(ValueKey('inputPhone'));
      expect(phoneField, findsOneWidget);

      var textFormField = tester.widget<TextFormField>(phoneField);
      expect(textFormField.controller?.text, "initialValue");
    });

    testWidgets(
      "when new phone is typed and confirm is pressed, then phone edit is triggered",
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MockGoRouterProvider(
              goRouter: mockGoRouter,
              child: SettingsEditPhone(viewModel: viewModel),
            ),
          ),
        );
        await tester.pump(
          Duration(milliseconds: 100),
        ); // Allow async load to complete

        final phoneField = find.byKey(ValueKey('inputPhone'));
        final btnSave = find.byKey(ValueKey('btnSave'));
        expect(phoneField, findsOneWidget);

        await tester.enterText(phoneField, "11987654321");
        await tester.pumpAndSettle();

        await tester.tap(btnSave);
        await tester.pumpAndSettle();

        verify(
          () => viewModel.profileRepository.updatePhone("11987654321"),
        ).called(1);
      },
    );

    testWidgets(
      "when invalid phone is typed and confirm is pressed, then phone edit is not triggered",
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: (SettingsEditPhone(viewModel: viewModel))),
        );
        await tester.pump(
          Duration(milliseconds: 100),
        ); // Allow async load to complete

        final phoneField = find.byKey(ValueKey('inputPhone'));
        final btnSave = find.byKey(ValueKey('btnSave'));
        expect(phoneField, findsOneWidget);

        // Empty the existing content of the field
        await tester.enterText(phoneField, "");
        await tester.pumpAndSettle();

        await tester.tap(btnSave);
        await tester.pumpAndSettle();

        verifyNever(() => viewModel.profileRepository.updatePhone(any()));
      },
    );
  });
}
