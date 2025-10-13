import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/repositories/document/document_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../data/repositories/session/session_repository.dart';
import '../../../data/repositories/auth/auth_repository.dart';

class LogoutAction {
  LogoutAction({
    required this.authRepository,
    required this.sessionRepository,
    required this.documentRepository,
    required this.profileRepository,
  });

  final AuthRepository authRepository;
  final SessionRepository sessionRepository;
  final DocumentRepository documentRepository;
  final ProfileRepository profileRepository;
  final Logger _log = Logger("LogoutAction");

  Future<Result<void, Exception>> execute() async {
    try {
      // Call API to logout
      await authRepository.logout();
      // Clear all tokens and state through session repository
      await sessionRepository.clearAuthToken();
      // Reset CacheDatabase through DocumentRepository
      await documentRepository.clearCache();
      // Reset other repositories if needed
      await profileRepository.clearCache();

      return Result.success(null);
    } catch (e, s) {
      _log.severe("Error during logout", e, s);
      return Result.error(
        Exception("Ocorreu um erro desconhecido ao tentar fazer logout."),
      );
    }
  }
}
