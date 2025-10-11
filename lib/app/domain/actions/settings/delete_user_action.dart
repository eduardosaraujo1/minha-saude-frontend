import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:multiple_result/multiple_result.dart';

class DeleteUserAction {
  DeleteUserAction({required this.profileRepository});

  final ProfileRepository profileRepository;

  Future<Result<void, Exception>> execute() async {
    throw UnimplementedError();
  }
}
