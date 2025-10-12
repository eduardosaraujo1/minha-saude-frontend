import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/settings/request_export_action.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../mocks/mock_profile_repository.dart';

void main() {
  late RequestExportAction requestExportAction;
  late ProfileRepository profileRepository;
  setUp(() {
    profileRepository = MockProfileRepository();
    requestExportAction = RequestExportAction(
      profileRepository: profileRepository,
    );
  });

  test("when executed calls appropriate method on repository", () async {
    when(
      () => profileRepository.requestDataExport(),
    ).thenAnswer((_) async => const Success(null));

    final result = await requestExportAction.execute();

    expect(result.isSuccess(), true);
    verify(() => profileRepository.requestDataExport()).called(1);
  });
}
