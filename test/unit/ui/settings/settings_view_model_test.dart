import 'package:minha_saude_frontend/app/domain/actions/auth/logout_action.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

class MockLogoutAction extends Mock implements LogoutAction {}

void main() {
  late MockLogoutAction mockLogoutAction;
  setUp(() {
    mockLogoutAction = MockLogoutAction();
  });

  test("When logout is called the logout action is executed", () {
    when(() => mockLogoutAction.execute()).thenAnswer(
      (_) async => Success(null),
      //
    );
    final viewModel = SettingsViewModel(logoutAction: mockLogoutAction);

    viewModel.logout();

    verify(() => mockLogoutAction.execute()).called(1);
  });

  test(
    "When requestDeletion is called the deleteAccount action is executed",
    () {
      // TODO: implement deleteAccount action and test it here
      // final viewModel = SettingsViewModel(logoutAction: mockLogoutAction);

      // viewModel.requestDeletion();

      // verify(() => mockLogoutAction.execute()).called(1);
    },
  );
}
