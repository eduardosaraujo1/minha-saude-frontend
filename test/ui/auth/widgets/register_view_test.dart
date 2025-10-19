import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/register_action.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/register_view_model.dart';
import 'package:minha_saude_frontend/app/ui/auth/widgets/register/register_navigator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../testing/app.dart';
import '../../../../testing/mocks/mock_go_router.dart';
import '../../../../testing/models/profile.dart';
import '../../../../testing/utils/command_it.dart';
import '../../../../testing/utils/format.dart';
import '../view_model/register_view_model_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      RegisterRequestModel(
        cpf: "123.456.789-09",
        dataNascimento: DateTime(1990, 1, 1),
        nome: "Mock User",
        telefone: "11953925678",
      ),
    );
  });

  /** Business Requirements
   * GROUP: TOS Screen
   * - can see Terms of Service text and accept button
   * - can tap accept button and go to Register Form screen
   * GROUP: Register Form Screen
   * - can see registration form field and submit button
   * - can submit form and complete registration
   */
  const String mockTos = 'terms-of-service';
  late MockGoRouter mockGoRouter;
  late RegisterViewModel viewModel;
  late MockRegisterAction mockRegisterAction;
  late MockGetTosAction mockGetTosAction;
  late Widget view;
  setUp(() {
    mockGoRouter = MockGoRouter();
    mockRegisterAction = MockRegisterAction();
    mockGetTosAction = MockGetTosAction();
    viewModel = RegisterViewModel(
      registerAction: mockRegisterAction,
      getTosAction: mockGetTosAction,
    );

    // GoRouter boilerplate
    when(() => mockGoRouter.canPop()).thenReturn(true);
    when(() => mockGoRouter.pop()).thenReturn(null);
    when(() => mockGoRouter.go(any())).thenReturn(null);

    // Successful register
    when(
      () => mockRegisterAction.execute(any()),
    ).thenAnswer((_) async => Success(null));

    // Successfully loaded TOS
    when(
      () => mockGetTosAction.execute(),
    ).thenAnswer((_) async => Success(mockTos));

    view = testApp(
      mockGoRouter: mockGoRouter,
      Scaffold(body: RegisterNavigator(viewModelFactory: () => viewModel)),
    );
  });

  group("TOS Screen", () {
    testWidgets("can see Terms of Service text and accept button", (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(view);
      await tester.pump(const Duration(milliseconds: 100));

      // Assert (TOS Text loaded)
      var val = viewModel.loadTosCommand.value;
      expect(val, isNotNull);
      expect(val!.isSuccess(), true);
      expect(val.tryGetSuccess(), mockTos);

      // Assert (accept button present)
      expect(find.byKey(const Key('btnAcceptTos')), findsOneWidget);

      await tester.disposeWidget();
    });
    testWidgets("can tap accept button and go to Register Form screen", (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(view);
      await tester.pump(const Duration(milliseconds: 100));

      // Act
      await tester.tap(find.byKey(const Key('btnAcceptTos')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(RegisterView), findsOneWidget);
      await tester.disposeWidget();
    });
  });

  group('Register Form Screen', () {
    Future<void> arrangeInRegisterForm(WidgetTester tester) async {
      await tester.pumpWidget(view);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const Key('btnAcceptTos')));
      await tester.pumpAndSettle();
    }

    void setFormFieldText(
      WidgetTester tester,
      Finder finder,
      String text,
    ) async {
      var formField = tester.widget<TextFormField>(finder);
      formField.controller?.text = text;
    }

    testWidgets("can see registration form field and submit button", (
      tester,
    ) async {
      // Arrange
      await arrangeInRegisterForm(tester);

      // Assert (form fields present)
      expect(find.byKey(const Key('inputNome')), findsOneWidget);
      expect(find.byKey(const Key('inputCpf')), findsOneWidget);
      expect(find.byKey(const Key('inputDataNascimento')), findsOneWidget);
      expect(find.byKey(const Key('inputTelefone')), findsOneWidget);
      expect(find.byKey(const Key('btnSubmit')), findsOneWidget);

      await tester.disposeWidget();
    });
    testWidgets("can submit form and complete registration", (tester) async {
      // Arrange
      await arrangeInRegisterForm(tester);
      final profile = randomProfile();
      final expectedRequest = RegisterRequestModel(
        nome: profile.nome,
        cpf: profile.cpf,
        dataNascimento: profile.dataNascimento,
        telefone: profile.telefone,
      );

      await tester.enterText(find.byKey(const Key('inputNome')), profile.nome);
      await tester.enterText(find.byKey(const Key('inputCpf')), profile.cpf);
      setFormFieldText(
        tester,
        find.byKey(const Key('inputDataNascimento')),
        formatDate(profile.dataNascimento),
      );
      await tester.enterText(
        find.byKey(const Key('inputTelefone')),
        profile.telefone,
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const Key('btnSubmit')));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Assert
      verify(() => mockRegisterAction.execute(expectedRequest)).called(1);

      await tester.disposeWidget();
    });
  });
}
