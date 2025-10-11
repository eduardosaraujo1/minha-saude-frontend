import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../mocks/mock_delete_user_action.dart';
import '../../../mocks/mock_logout_action.dart';

void main() {
  late MockLogoutAction mockLogoutAction;
  late MockDeleteUserAction mockDeleteUserAction;
  late SettingsViewModel viewModel;
  setUp(() {
    mockLogoutAction = MockLogoutAction();
    mockDeleteUserAction = MockDeleteUserAction();
    viewModel = SettingsViewModel(
      logoutAction: mockLogoutAction,
      deleteUserAction: mockDeleteUserAction,
    );
  });

  test("When logout is called the logout action is executed", () {
    when(
      () => mockLogoutAction.execute(),
    ).thenAnswer((_) async => Success(null));
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

  test("when export data is called, export data action is executed", () {});
}
