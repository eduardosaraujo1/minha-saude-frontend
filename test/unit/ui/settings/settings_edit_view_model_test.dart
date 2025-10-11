import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_edit_view_model.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_view_model.dart';
import 'package:minha_saude_frontend/app/ui/settings/widgets/edit/settings_edit_name.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../mocks/mock_profile_repository.dart';

void main() {
  late ProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
  });

  test("when updateName is called, profile repository is called", () async {
    // when(
    //   () => mockProfileRepository.updateName(any()),
    // ).thenAnswer((_) async => Success(null));
    // final viewModel = SettingsEditViewModel(
    //   profileRepository: mockProfileRepository,
    // );

    // await viewModel.updateName("new name");

    // verify(() => mockProfileRepository.updateName("new name")).called(1);
  });
}
