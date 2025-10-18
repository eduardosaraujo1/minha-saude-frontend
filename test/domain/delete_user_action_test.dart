import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/session/session_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/settings/delete_user_action.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../testing/mocks/repositories/mock_profile_repository.dart';
import '../../testing/mocks/repositories/mock_session_repository.dart';

void main() {
  late DeleteUserAction deleteUserAction;
  late ProfileRepository profileRepository;
  late SessionRepository sessionRepository;
  setUp(() {
    profileRepository = MockProfileRepository();
    sessionRepository = MockSessionRepository();
    deleteUserAction = DeleteUserAction(
      sessionRepository: sessionRepository,
      profileRepository: profileRepository,
    );
  });

  test("when executed calls appropriate method on repository", () async {
    when(
      () => profileRepository.deleteAccount(),
    ).thenAnswer((_) async => const Success(null));
    when(() => sessionRepository.logout()).thenAnswer((_) async {});

    final result = await deleteUserAction.execute();

    expect(result.isSuccess(), true);
    verify(() => profileRepository.deleteAccount()).called(1);
    verify(() => sessionRepository.logout()).called(1);
  });
}
