import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:multiple_result/multiple_result.dart';

class RequestExportAction {
  RequestExportAction({required this.profileRepository});
  final ProfileRepository profileRepository;
  final Logger _log = Logger("RequestExportAction");

  Future<Result<void, Exception>> execute() async {
    try {
      final result = await profileRepository.requestDataExport();

      if (result.isError()) {
        return Error(
          Exception("Não foi possível solicitar a exportação dos dados."),
        );
      }

      return Success(null);
    } catch (e, s) {
      _log.severe("Erro ao solicitar exportação de dados: $e", e, s);
      return Error(
        Exception("Não foi possível solicitar a exportação dos dados."),
      );
    }
  }
}
