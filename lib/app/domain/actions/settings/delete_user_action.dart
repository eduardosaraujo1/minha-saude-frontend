import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../data/repositories/profile/profile_repository.dart';

class DeleteUserAction {
  DeleteUserAction({required this.profileRepository});

  final ProfileRepository profileRepository;

  final Logger _log = Logger("DeleteUserAction");

  Future<Result<void, Exception>> execute() async {
    try {
      final result = await profileRepository.deleteAccount();

      if (result.isError()) {
        return Error(
          Exception("Não foi possível solicitar a exclusão da conta."),
        );
      }

      return Success(null);
    } catch (e, s) {
      _log.severe("Erro ao solicitar exclusão da conta: $e", e, s);
      return Error(
        Exception("Não foi possível solicitar a exclusão da conta."),
      );
    }
  }
}
