import 'package:minha_saude_frontend/app/domain/actions/auth/register_action.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/old_register_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

class MockRegisterAction extends Mock implements RegisterAction {}

void main() {
  // UNIT
  // Has correct state after register command with valid data
  // Has correct state after register command with invalid data

  late OldRegisterViewModel viewModel;
  late RegisterAction mockRegisterAction;
  setUp(() {
    mockRegisterAction = MockRegisterAction();
    when(
      () => mockRegisterAction.execute(
        nome: any(named: 'nome'),
        cpf: any(named: 'cpf'),
        dataNascimento: any(named: 'dataNascimento'),
        telefone: any(named: 'telefone'),
      ),
    ).thenAnswer((_) async => Success(null));
    viewModel = OldRegisterViewModel(registerAction: mockRegisterAction);
  });

  test("it has correct state after register with valid data", () async {
    viewModel.registerCommand.execute(
      RegisterRequestModel(
        nome: "Valid Name",
        cpf: "12345678900",
        dataNascimento: DateTime(2000, 01, 01),
        telefone: "11999999999",
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    var val = viewModel.registerCommand.value;

    expect(val, isNotNull);
    expect(val!.isSuccess(), true);
  });
  test("it has correct state after register with invalid data", () async {
    // Mock failure
    when(
      () => mockRegisterAction.execute(
        nome: "",
        cpf: "",
        dataNascimento: any(named: 'dataNascimento'),
        telefone: "",
      ),
    ).thenAnswer((_) async => Error(Exception("Invalid data")));

    viewModel.registerCommand.execute(
      RegisterRequestModel(
        nome: "",
        cpf: "",
        dataNascimento: DateTime(2000, 01, 01),
        telefone: "",
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    var val = viewModel.registerCommand.value;
    expect(val, isNotNull);
    expect(val!.isSuccess(), false);
  });
}
