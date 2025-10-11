import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/settings/delete_user_action.dart';

import '../../mocks/mock_profile_repository.dart';

void main() {
  late DeleteUserAction deleteUserAction;
  late ProfileRepository profileRepository;
  setUp(() {
    profileRepository = MockProfileRepository();
    deleteUserAction = DeleteUserAction(profileRepository: profileRepository);
  });
}
