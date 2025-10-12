import 'package:command_it/command_it.dart';
import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/actions/settings/request_export_action.dart';
import '../../../domain/models/profile/profile.dart';
import '../../../domain/actions/settings/delete_user_action.dart';
import '../../../domain/actions/auth/logout_action.dart';

class SettingsViewModel {
  SettingsViewModel({
    required this.profileRepository,
    required this.logoutAction,
    required this.deleteUserAction,
    required this.requestExportAction,
  }) {
    loadProfile = Command.createAsyncNoParam<Result<Profile, Exception>?>(
      _loadProfile,
      initialValue: null,
    );
    requestDeletionCommand =
        Command.createAsyncNoParam<Result<void, Exception>?>(
          _requestDeletion,
          initialValue: null,
        );
    requestExportCommand = Command.createAsyncNoParam<Result<void, Exception>?>(
      _requestExport,
      initialValue: null,
    );
    profileRepository.addListener(_reload);
  }

  void _reload() {
    loadProfile.execute(); // reload profile on repository changes
  }

  final LogoutAction logoutAction;
  final DeleteUserAction deleteUserAction;
  final RequestExportAction requestExportAction;

  late final Command<void, Result<Profile, Exception>?> loadProfile;
  late final Command<void, Result<void, Exception>?> requestDeletionCommand;
  late final Command<void, Result<void, Exception>?> requestExportCommand;

  final ProfileRepository profileRepository;

  final Logger _log = Logger("SettingsViewModel");

  void logout() {
    logoutAction.execute();
  }

  Future<Result<void, Exception>?> _requestDeletion() async {
    return await deleteUserAction.execute();
  }

  Future<Result<void, Exception>?> _requestExport() async {
    return await requestExportAction.execute();
  }

  Future<Result<Profile, Exception>?> _loadProfile() async {
    try {
      final result = await profileRepository.getProfile();
      if (result.isError()) {
        return Error(
          Exception("Não foi possível carregar os dados do perfil."),
        );
      }
      return result;
    } catch (e, s) {
      _log.severe("Error loading profile", e, s);
      return Error(Exception("Não foi possível carregar os dados do perfil."));
    }
  }

  void dispose() {
    profileRepository.removeListener(_reload);
  }
}
