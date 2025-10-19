import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/get_tos_action.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/register_action.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/register_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../testing/models/profile.dart';

class MockRegisterAction extends Mock implements RegisterAction {}

class MockGetTosAction extends Mock implements GetTosAction {}

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

  /** Business Requirements (ViewModel, not View)
   * - can load Terms of Service
   * - can submit registration form
   * - handles errors when loading Terms of Service fails
   * - handles errors when registration fails
   */
  const String mockTos = 'terms-of-service';
  late MockRegisterAction mockRegisterAction;
  late MockGetTosAction mockGetTosAction;
  late RegisterViewModel viewModel;
  late RegisterRequestModel requestModel;
  setUp(() {
    final mockProfile = randomProfile();
    requestModel = RegisterRequestModel(
      nome: mockProfile.nome,
      cpf: mockProfile.cpf,
      dataNascimento: mockProfile.dataNascimento,
      telefone: mockProfile.telefone,
    );

    mockRegisterAction = MockRegisterAction();
    mockGetTosAction = MockGetTosAction();

    // Successful register
    when(
      () => mockRegisterAction.execute(any()),
    ).thenAnswer((_) async => Success(null));

    // Successfully loaded TOS
    when(
      () => mockGetTosAction.execute(),
    ).thenAnswer((_) async => Success(mockTos));

    viewModel = RegisterViewModel(
      registerAction: mockRegisterAction,
      getTosAction: mockGetTosAction,
    );
  });

  group("Success Cases", () {
    test('can load Terms of Service', () async {
      viewModel.loadTosCommand.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      var val = viewModel.loadTosCommand.value;

      expect(val, isNotNull);
      expect(val!.isSuccess(), true);
      expect(val.tryGetSuccess(), mockTos);
    });
    test('can submit registration form', () async {
      // Act
      viewModel.registerCommand.execute(requestModel);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      var val = viewModel.registerCommand.value;
      expect(val, isNotNull);
      expect(val!.isSuccess(), true);
      verify(() => mockRegisterAction.execute(requestModel)).called(1);
    });
  });

  group("Error Handling", () {
    test("handles errors when loading Terms of Service fails", () async {
      // Arrange
      when(
        () => mockGetTosAction.execute(),
      ).thenAnswer((_) async => Error(Exception("Failed to load TOS")));

      // Act
      viewModel.loadTosCommand.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      var val = viewModel.loadTosCommand.value;
      expect(val, isNotNull);
      expect(val!.isError(), true);
    });
    test(
      'handles errors when registration fails with expired login exception',
      () async {
        // Arrange
        when(() => mockRegisterAction.execute(any())).thenAnswer(
          (_) async => Error(ExpiredLoginException("Session expired")),
        );

        // Act
        viewModel.registerCommand.execute(requestModel);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        var val = viewModel.registerCommand.value;
        expect(val, isNotNull);
        expect(val!.isError(), true);
        expect(val.tryGetError(), isA<ExpiredLoginException>());
      },
    );
    test(
      'handles errors when registration fails with unexpected register exception',
      () async {
        // Arrange
        when(() => mockRegisterAction.execute(any())).thenAnswer(
          (_) async => Error(UnexpectedRegisterException("Unexpected error")),
        );

        // Act
        viewModel.registerCommand.execute(requestModel);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        var val = viewModel.registerCommand.value;
        expect(val, isNotNull);
        expect(val!.isError(), true);
        expect(val.tryGetError(), isA<UnexpectedRegisterException>());
      },
    );
  });
}
