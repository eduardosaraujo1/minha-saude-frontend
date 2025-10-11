import '../../../domain/actions/settings/delete_user_action.dart';
import '../../../domain/actions/auth/logout_action.dart';

class SettingsViewModel {
  SettingsViewModel({
    required this.logoutAction,
    required this.deleteUserAction,
  });

  final LogoutAction logoutAction;
  final DeleteUserAction deleteUserAction;

  void logout() {
    logoutAction.execute();
  }

  void requestDeletion() {
    // TODO: implementar requisição de exclusão de conta
    logoutAction.execute();
  }
}
