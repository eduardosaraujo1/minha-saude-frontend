import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/repositories/document/document_repository.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../data/repositories/session/session_repository.dart';
import '../../../data/repositories/auth/auth_repository.dart';

class LogoutAction {
  LogoutAction({
    required AuthRepository authRepository,
    required SessionRepository sessionRepository,
    required DocumentRepository documentRepository,
  }) : _authRepository = authRepository,
       _sessionRepository = sessionRepository,
       _documentRepository = documentRepository;

  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;
  final DocumentRepository _documentRepository;
  final Logger _log = Logger("LogoutAction");

  Future<Result<void, Exception>> execute() async {
    try {
      // Call API to logout
      await _authRepository.logout();
      // Clear all tokens and state through session repository
      await _sessionRepository.clearAuthToken();
      // Reset CacheDatabase through DocumentRepository
      await _documentRepository.resetCache();

      return Result.success(null);
    } catch (e, s) {
      _log.severe("Error during logout", e, s);
      return Result.error(
        Exception("Ocorreu um erro desconhecido ao tentar fazer logout."),
      );
    }
  }
}
