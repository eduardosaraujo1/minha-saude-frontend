import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/register_action.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/old_register_view_model.dart';
import 'package:minha_saude_frontend/app/ui/auth/widgets/register_view.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../testing/app.dart';
import '../../../../testing/mocks/mock_go_router.dart';
import '../../../../testing/utils/command_it.dart';

class MockRegisterAction extends Mock implements RegisterAction {}

void main() {
  late OldRegisterViewModel viewModel;
  late RegisterAction mockRegisterAction;
  late MockGoRouter mockGoRouter;
  late Widget view;

  setUp(() {
    mockRegisterAction = MockRegisterAction();
    mockGoRouter = MockGoRouter();

    // Mock GoRouter methods used by the view
    when(() => mockGoRouter.canPop()).thenReturn(true);

    viewModel = OldRegisterViewModel(registerAction: mockRegisterAction);
    view = testApp(
      Scaffold(body: OldRegisterView(() => viewModel)),
      mockGoRouter: mockGoRouter,
    );
  });

  group("UNIT - Form Fields", () {
    testWidgets("it can find all form fields and confirm button", (
      tester,
    ) async {
      await tester.pumpWidget(view);

      expect(find.byKey(const ValueKey('nomeField')), findsOneWidget);
      expect(find.byKey(const ValueKey('cpfField')), findsOneWidget);
      expect(find.byKey(const ValueKey('dataNascimentoField')), findsOneWidget);
      expect(find.byKey(const ValueKey('telefoneField')), findsOneWidget);
      expect(find.byKey(const ValueKey('btnConfirm')), findsOneWidget);

      await tester.disposeWidget();
    });
  });

  group("Form Submission Validation", () {
    setUp(() {
      when(
        () => mockRegisterAction.execute(
          nome: any(named: 'nome'),
          cpf: any(named: 'cpf'),
          dataNascimento: any(named: 'dataNascimento'),
          telefone: any(named: 'telefone'),
        ),
      ).thenAnswer((_) async => const Success(null));
    });

    testWidgets("it rejects submission when nome is empty", (tester) async {
      await tester.pumpWidget(view);

      // Leave nome empty
      await tester.enterText(
        find.byKey(const ValueKey('cpfField')),
        '529.982.247-25',
      );
      setFormFieldText(
        find.byKey(const ValueKey('dataNascimentoField')),
        '01/01/1990',
        tester,
      );
      await tester.enterText(
        find.byKey(const ValueKey('telefoneField')),
        '(11) 98765-4321',
      );

      await tester.tap(find.byKey(const ValueKey('btnConfirm')));
      await tester.pump();

      // Verify register was NOT called
      verifyNever(
        () => mockRegisterAction.execute(
          nome: any(named: 'nome'),
          cpf: any(named: 'cpf'),
          dataNascimento: any(named: 'dataNascimento'),
          telefone: any(named: 'telefone'),
        ),
      );

      await tester.disposeWidget();
    });

    testWidgets("it rejects submission when CPF is empty", (tester) async {
      await tester.pumpWidget(view);

      await tester.enterText(
        find.byKey(const ValueKey('nomeField')),
        'John Doe',
      );
      // Leave CPF empty
      setFormFieldText(
        find.byKey(const ValueKey('dataNascimentoField')),
        '01/01/1990',
        tester,
      );
      await tester.enterText(
        find.byKey(const ValueKey('telefoneField')),
        '(11) 98765-4321',
      );

      await tester.tap(find.byKey(const ValueKey('btnConfirm')));
      await tester.pump();

      verifyNever(
        () => mockRegisterAction.execute(
          nome: any(named: 'nome'),
          cpf: any(named: 'cpf'),
          dataNascimento: any(named: 'dataNascimento'),
          telefone: any(named: 'telefone'),
        ),
      );

      await tester.disposeWidget();
    });

    testWidgets("it rejects submission when CPF is invalid", (tester) async {
      await tester.pumpWidget(view);

      await tester.enterText(
        find.byKey(const ValueKey('nomeField')),
        'John Doe',
      );
      await tester.enterText(
        find.byKey(const ValueKey('cpfField')),
        '111.111.111-11', // Invalid CPF
      );
      setFormFieldText(
        find.byKey(const ValueKey('dataNascimentoField')),
        '01/01/1990',
        tester,
      );
      await tester.enterText(
        find.byKey(const ValueKey('telefoneField')),
        '(11) 98765-4321',
      );

      await tester.tap(find.byKey(const ValueKey('btnConfirm')));
      await tester.pump();

      verifyNever(
        () => mockRegisterAction.execute(
          nome: any(named: 'nome'),
          cpf: any(named: 'cpf'),
          dataNascimento: any(named: 'dataNascimento'),
          telefone: any(named: 'telefone'),
        ),
      );

      await tester.disposeWidget();
    });

    testWidgets("it rejects submission when data de nascimento is empty", (
      tester,
    ) async {
      await tester.pumpWidget(view);

      await tester.enterText(
        find.byKey(const ValueKey('nomeField')),
        'John Doe',
      );
      await tester.enterText(
        find.byKey(const ValueKey('cpfField')),
        '529.982.247-25',
      );
      // Leave date empty
      await tester.enterText(
        find.byKey(const ValueKey('telefoneField')),
        '(11) 98765-4321',
      );

      await tester.tap(find.byKey(const ValueKey('btnConfirm')));
      await tester.pump();

      verifyNever(
        () => mockRegisterAction.execute(
          nome: any(named: 'nome'),
          cpf: any(named: 'cpf'),
          dataNascimento: any(named: 'dataNascimento'),
          telefone: any(named: 'telefone'),
        ),
      );

      await tester.disposeWidget();
    });

    testWidgets("it rejects submission when telefone is empty", (tester) async {
      await tester.pumpWidget(view);

      await tester.enterText(
        find.byKey(const ValueKey('nomeField')),
        'John Doe',
      );
      await tester.enterText(
        find.byKey(const ValueKey('cpfField')),
        '529.982.247-25',
      );
      setFormFieldText(
        find.byKey(const ValueKey('dataNascimentoField')),
        '01/01/1990',
        tester,
      );
      // Leave telefone empty

      await tester.tap(find.byKey(const ValueKey('btnConfirm')));
      await tester.pump();

      verifyNever(
        () => mockRegisterAction.execute(
          nome: any(named: 'nome'),
          cpf: any(named: 'cpf'),
          dataNascimento: any(named: 'dataNascimento'),
          telefone: any(named: 'telefone'),
        ),
      );

      await tester.disposeWidget();
    });

    testWidgets("it rejects submission when telefone is invalid", (
      tester,
    ) async {
      await tester.pumpWidget(view);

      await tester.enterText(
        find.byKey(const ValueKey('nomeField')),
        'John Doe',
      );
      await tester.enterText(
        find.byKey(const ValueKey('cpfField')),
        '529.982.247-25',
      );
      setFormFieldText(
        find.byKey(const ValueKey('dataNascimentoField')),
        '01/01/1990',
        tester,
      );
      await tester.enterText(
        find.byKey(const ValueKey('telefoneField')),
        '1234567890', // Invalid format
      );

      await tester.tap(find.byKey(const ValueKey('btnConfirm')));
      await tester.pump();

      verifyNever(
        () => mockRegisterAction.execute(
          nome: any(named: 'nome'),
          cpf: any(named: 'cpf'),
          dataNascimento: any(named: 'dataNascimento'),
          telefone: any(named: 'telefone'),
        ),
      );

      await tester.disposeWidget();
    });

    testWidgets("it accepts submission when all fields are valid", (
      tester,
    ) async {
      await tester.pumpWidget(view);

      // Fill in valid form data
      await tester.enterText(
        find.byKey(const ValueKey('nomeField')),
        'John Doe',
      );
      await tester.enterText(
        find.byKey(const ValueKey('cpfField')),
        '529.982.247-25',
      );
      setFormFieldText(
        find.byKey(const ValueKey('dataNascimentoField')),
        '01/01/1990',
        tester,
      );
      await tester.enterText(
        find.byKey(const ValueKey('telefoneField')),
        '(11) 98765-4321',
      );

      await tester.tap(find.byKey(const ValueKey('btnConfirm')));
      await tester.pump();

      // Wait for async operations
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => mockRegisterAction.execute(
          nome: 'John Doe',
          cpf: '529.982.247-25',
          dataNascimento: DateTime(1990, 1, 1),
          telefone: '(11) 98765-4321',
        ),
      ).called(1);

      await tester.disposeWidget();
    });
  });

  group("Submission Protection", () {
    setUp(() {
      when(
        () => mockRegisterAction.execute(
          nome: any(named: 'nome'),
          cpf: any(named: 'cpf'),
          dataNascimento: any(named: 'dataNascimento'),
          telefone: any(named: 'telefone'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return const Success(null);
      });
    });

    testWidgets("it prevents duplicate submissions while processing", (
      tester,
    ) async {
      await tester.pumpWidget(view);

      // Fill in valid form data
      await tester.enterText(
        find.byKey(const ValueKey('nomeField')),
        'John Doe',
      );
      await tester.enterText(
        find.byKey(const ValueKey('cpfField')),
        '529.982.247-25',
      );
      setFormFieldText(
        find.byKey(const ValueKey('dataNascimentoField')),
        '01/01/1990',
        tester,
      );
      await tester.enterText(
        find.byKey(const ValueKey('telefoneField')),
        '(11) 98765-4321',
      );

      await tester.tap(find.byKey(const ValueKey('btnConfirm')));
      await tester.pump(); // Start async work

      // Try to submit again immediately
      await tester.tap(find.byKey(const ValueKey('btnConfirm')));
      await tester.pump();

      // Wait for operation to complete
      await tester.pumpAndSettle();

      // Verify register was only called once (not twice)
      verify(
        () => mockRegisterAction.execute(
          nome: 'John Doe',
          cpf: '529.982.247-25',
          dataNascimento: DateTime(1990, 1, 1),
          telefone: '(11) 98765-4321',
        ),
      ).called(1);

      await tester.disposeWidget();
    });
  });
}

void setFormFieldText(Finder finder, String text, WidgetTester tester) async {
  var formField = tester.widget<TextFormField>(finder);
  formField.controller?.text = text;
}
