import 'package:intl/intl.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/profile/profile.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_edit_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../mocks/mock_profile_repository.dart';

void main() {
  late ProfileRepository profileRepository;
  late SettingsEditViewModel viewModel;

  setUp(() {
    profileRepository = MockProfileRepository();
  });

  test(
    "when each update method is called, the corresponding profile repository method should be called",
    () async {
      final viewModel = SettingsEditViewModel(
        fieldType: SettingsEditField.name,
        profileRepository: profileRepository,
      );

      when(
        () => profileRepository.updateBirthdate(any()),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => profileRepository.updateName(any()),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => profileRepository.updatePhone(any()),
      ).thenAnswer((_) async => const Success(null));

      var dateTime = DateTime(2020, 1, 1);
      await viewModel.updateBirthdate(dateTime);
      verify(() => profileRepository.updateBirthdate(dateTime)).called(1);

      var name = "new name";
      await viewModel.updateName(name);
      verify(() => profileRepository.updateName(name)).called(1);

      var phone = "99999999999";
      await viewModel.updatePhone(phone);
      verify(() => profileRepository.updatePhone(phone)).called(1);
    },
  );

  group("Name View Model", () {
    setUp(() {
      viewModel = SettingsEditViewModel(
        fieldType: SettingsEditField.name,
        profileRepository: profileRepository,
      );
    });
    test(
      "given a valid profileRepository when load is requested then calls getProfile",
      () async {
        const fakeName = "Test User";
        when(() => profileRepository.getProfile()).thenAnswer(
          (_) async => Success(
            Profile(
              id: "0",
              cpf: "12345678909",
              email: "",
              dataNascimento: DateTime(2000, 1, 1),
              nome: fakeName,
              metodoAutenticacao: AuthMethod.email,
              telefone: "99999999999",
            ),
          ),
        );

        viewModel.loadCurrentValue.execute();
        await Future.delayed(const Duration(milliseconds: 200));

        verify(() => profileRepository.getProfile()).called(1);
        expect(viewModel.loadCurrentValue.value, isNotNull);
        expect(viewModel.loadCurrentValue.value!.isSuccess(), isTrue);
        expect(viewModel.loadCurrentValue.value!.tryGetSuccess()!, fakeName);
      },
    );
  });
  group("Birthdate View Model", () {
    setUp(() {
      viewModel = SettingsEditViewModel(
        fieldType: SettingsEditField.birthdate,
        profileRepository: profileRepository,
      );
    });
    test(
      "given a valid profileRepository when load is requested then calls getProfile",
      () async {
        final mockDay = DateTime(2000, 1, 1);
        when(() => profileRepository.getProfile()).thenAnswer((_) async {
          return Success(
            Profile(
              id: "0",
              cpf: "12345678909",
              email: "",
              dataNascimento: mockDay,
              nome: "Test User",
              metodoAutenticacao: AuthMethod.email,
              telefone: "99999999999",
            ),
          );
        });

        viewModel.loadCurrentValue.execute();
        await Future.delayed(const Duration(milliseconds: 200));

        verify(() => profileRepository.getProfile()).called(1);
        expect(viewModel.loadCurrentValue.value, isNotNull);
        expect(viewModel.loadCurrentValue.value!.isSuccess(), isTrue);
        expect(
          viewModel.loadCurrentValue.value!.tryGetSuccess()!,
          DateFormat("dd/MM/yyyy").format(mockDay),
        );
      },
    );
  });
  group("Phone View Model", () {
    setUp(() {
      viewModel = SettingsEditViewModel(
        fieldType: SettingsEditField.phone,
        profileRepository: profileRepository,
      );
    });
    test(
      "given a valid profileRepository when load is requested then calls getProfile",
      () async {
        final fakePhone = "99999999999";
        when(() => profileRepository.getProfile()).thenAnswer(
          (_) async => Success(
            Profile(
              id: "0",
              cpf: "12345678909",
              email: "",
              dataNascimento: DateTime(2000, 1, 1),
              nome: "Test User",
              metodoAutenticacao: AuthMethod.email,
              telefone: fakePhone,
            ),
          ),
        );

        viewModel.loadCurrentValue.execute();
        await Future.delayed(const Duration(milliseconds: 200));

        verify(() => profileRepository.getProfile()).called(1);
        expect(viewModel.loadCurrentValue.value, isNotNull);
        expect(viewModel.loadCurrentValue.value!.isSuccess(), isTrue);
        expect(viewModel.loadCurrentValue.value!.tryGetSuccess()!, fakePhone);
      },
    );
  });
}
