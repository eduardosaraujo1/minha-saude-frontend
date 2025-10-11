import '../../../domain/actions/auth/logout_action.dart';

class SettingsViewModel {
  SettingsViewModel({required this.logoutAction});

  final LogoutAction logoutAction;

  void logout() {
    logoutAction.execute();
  }

  void requestDeletion() {
    // TODO: implementar requisição de exclusão de conta
    logoutAction.execute();
  }
}
