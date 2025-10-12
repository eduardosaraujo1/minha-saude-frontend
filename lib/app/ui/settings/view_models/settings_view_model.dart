import 'package:command_it/command_it.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/profile/profile.dart';
import '../../../domain/actions/settings/delete_user_action.dart';
import '../../../domain/actions/auth/logout_action.dart';

class SettingsViewModel {
  SettingsViewModel({
    required this.logoutAction,
    required this.deleteUserAction,
  }) {
    loadProfile = Command.createAsyncNoParam<Result<Profile, Exception>?>(
      _loadProfile,
      initialValue: null,
    );
  }

  final LogoutAction logoutAction;
  final DeleteUserAction deleteUserAction;

  late final Command<void, Result<Profile, Exception>?> loadProfile;

  void logout() {
    logoutAction.execute();
  }

  void requestDeletion() {
    deleteUserAction.execute();
  }

  Future<Result<Profile, Exception>?> _loadProfile() async {
    throw UnimplementedError();
  }
}
