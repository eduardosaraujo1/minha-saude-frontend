import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/profile/profile.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../mocks/mock_delete_user_action.dart';
import '../../../mocks/mock_logout_action.dart';
import '../../../mocks/mock_profile_repository.dart';
import '../../../mocks/mock_request_export_action.dart';

void main() {
  late MockLogoutAction mockLogoutAction;
  late MockDeleteUserAction mockDeleteUserAction;
  late MockRequestExportAction mockRequestExportAction;
  late ProfileRepository profileRepository;
  late SettingsViewModel viewModel;
  setUp(() {
    mockLogoutAction = MockLogoutAction();
    mockDeleteUserAction = MockDeleteUserAction();
    mockRequestExportAction = MockRequestExportAction();
    profileRepository = MockProfileRepository();
    viewModel = SettingsViewModel(
      profileRepository: profileRepository,
      logoutAction: mockLogoutAction,
      requestExportAction: mockRequestExportAction,
      deleteUserAction: mockDeleteUserAction,
    );
  });

  test(
    "When load is called, Profile data becomes available on action",
    () async {
      final profile = Profile(
        id: "0",
        email: "example@gmail.com",
        cpf: "12345678909",
        nome: "initialValue",
        telefone: "initialValue",
        dataNascimento: DateTime(2020, 1, 1),
        metodoAutenticacao: AuthMethod.google,
      );
      when(
        () => profileRepository.getProfile(),
      ).thenAnswer((_) async => Success(profile));
      viewModel.loadProfile.execute();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.loadProfile.value, isNotNull);
      expect(viewModel.loadProfile.value?.tryGetSuccess(), profile);
    },
  );

  test("When logout is called the logout action is executed", () {
    when(
      () => mockLogoutAction.execute(),
    ).thenAnswer((_) async => Success(null));
    viewModel.logout();

    verify(() => mockLogoutAction.execute()).called(1);
  });

  test(
    "When requestDeletion is called the deleteAccount action is executed",
    () async {
      when(
        () => mockDeleteUserAction.execute(),
      ).thenAnswer((_) async => const Success(null));
      viewModel.requestDeletionCommand.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockDeleteUserAction.execute()).called(1);
    },
  );

  test("when export data is called, export data action is executed", () async {
    when(
      () => mockRequestExportAction.execute(),
    ).thenAnswer((_) async => const Success(null));

    viewModel.requestExportAction.execute();
    await Future.delayed(const Duration(milliseconds: 100));

    verify(() => mockRequestExportAction.execute()).called(1);
  });
}
