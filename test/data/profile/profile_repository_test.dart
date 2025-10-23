import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/services/api/deprecating/profile/models/profile_api_model.dart';
import 'package:minha_saude_frontend/app/data/services/api/deprecating/profile/profile_api_client.dart';
import 'package:minha_saude_frontend/app/domain/models/profile/profile.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../testing/models/profile.dart';

class MockProfileApiClient extends Mock implements ProfileApiClient {}

void main() {
  late ProfileApiClient mockProfileApiClient;
  late ProfileRepository profileRepository;
  late Profile fakeProfile;
  late ProfileApiModel fakeProfileApi;

  setUp(() {
    mockProfileApiClient = MockProfileApiClient();
    profileRepository = ProfileRepositoryImpl(
      profileApiClient: mockProfileApiClient,
    );

    fakeProfile = randomProfile();
    fakeProfileApi = ProfileApiModel(
      id: fakeProfile.id,
      nome: fakeProfile.nome,
      cpf: fakeProfile.cpf,
      email: fakeProfile.email,
      telefone: fakeProfile.telefone,
      dataNascimento: fakeProfile.dataNascimento,
      metodoAutenticacao: fakeProfile.metodoAutenticacao == AuthMethod.google
          ? 'google'
          : 'email',
    );

    // Default: getProfile returns success
    when(
      () => mockProfileApiClient.getProfile(),
    ).thenAnswer((_) async => Success(fakeProfileApi));
  });

  group("Get Current Profile", () {
    test("it returns profile from ApiClient", () async {
      final result = await profileRepository.getProfile();

      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess(), fakeProfile);
    });

    test("it caches profile and only calls ApiClient once", () async {
      final result1 = await profileRepository.getProfile();

      // Change mock to return error
      when(
        () => mockProfileApiClient.getProfile(),
      ).thenAnswer((_) async => Error(Exception('Network error')));

      final result2 = await profileRepository.getProfile();

      expect(result1.isSuccess(), true);
      expect(result1.tryGetSuccess(), fakeProfile);

      expect(result2.isSuccess(), true);
      expect(result2.tryGetSuccess(), fakeProfile);

      verify(() => mockProfileApiClient.getProfile()).called(1);
    });

    test("it bypasses cache when forceRefresh is true", () async {
      final result1 = await profileRepository.getProfile();

      // Change mock to return updated profile
      final updatedProfile = fakeProfile.copyWith(
        nome: 'Updated Name',
        telefone: '11988888888',
      );
      final updatedProfileApi = ProfileApiModel(
        id: updatedProfile.id,
        nome: updatedProfile.nome,
        cpf: updatedProfile.cpf,
        email: updatedProfile.email,
        telefone: updatedProfile.telefone,
        dataNascimento: updatedProfile.dataNascimento,
        metodoAutenticacao:
            updatedProfile.metodoAutenticacao == AuthMethod.google
            ? 'google'
            : 'email',
      );
      when(
        () => mockProfileApiClient.getProfile(),
      ).thenAnswer((_) async => Success(updatedProfileApi));

      final result2 = await profileRepository.getProfile(forceRefresh: true);

      expect(result1.isSuccess(), true);
      expect(result1.tryGetSuccess(), fakeProfile);

      expect(result2.isSuccess(), true);
      expect(result2.tryGetSuccess(), updatedProfile);

      verify(() => mockProfileApiClient.getProfile()).called(2);
    });
  });

  group("Change Name", () {
    setUp(() {
      when(
        () => mockProfileApiClient.updateName(any()),
      ).thenAnswer((_) async => const Success('Updated Name'));
    });

    test("it returns success from ApiClient", () async {
      final result = await profileRepository.updateName('Updated Name');
      expect(result.isSuccess(), true);
    });

    test("it returns error from ApiClient", () async {
      when(
        () => mockProfileApiClient.updateName(any()),
      ).thenAnswer((_) async => Error(Exception('Network error')));

      final result = await profileRepository.updateName('Updated Name');
      expect(result.isError(), true);
    });
    test("it refreshes cache after update", () async {
      await profileRepository.getProfile();

      final updatedProfile = fakeProfile.copyWith(nome: 'Updated Name');
      final updatedProfileApi = ProfileApiModel(
        id: updatedProfile.id,
        nome: updatedProfile.nome,
        cpf: updatedProfile.cpf,
        email: updatedProfile.email,
        telefone: updatedProfile.telefone,
        dataNascimento: updatedProfile.dataNascimento,
        metodoAutenticacao:
            updatedProfile.metodoAutenticacao == AuthMethod.google
            ? 'google'
            : 'email',
      );

      when(
        () => mockProfileApiClient.getProfile(),
      ).thenAnswer((_) async => Success(updatedProfileApi));

      await profileRepository.updateName('Updated Name');

      final result = await profileRepository.getProfile();

      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess()?.nome, 'Updated Name');
    });
  });

  group("Change Birthdate", () {
    setUp(() {
      when(
        () => mockProfileApiClient.updateBirthdate(any()),
      ).thenAnswer((_) async => const Success('1995-05-05'));
    });

    test("it returns success from ApiClient", () async {
      final result = await profileRepository.updateBirthdate(
        DateTime(1995, 5, 5),
      );
      expect(result.isSuccess(), true);
    });

    test("it returns error from ApiClient", () async {
      when(
        () => mockProfileApiClient.updateBirthdate(any()),
      ).thenAnswer((_) async => Error(Exception('Network error')));

      final result = await profileRepository.updateBirthdate(
        DateTime(1995, 5, 5),
      );
      expect(result.isError(), true);
    });
    test("it refreshes cache after update", () async {
      await profileRepository.getProfile();

      final newDate = DateTime(1995, 5, 5);
      final updatedProfile = fakeProfile.copyWith(dataNascimento: newDate);
      final updatedProfileApi = ProfileApiModel(
        id: updatedProfile.id,
        nome: updatedProfile.nome,
        cpf: updatedProfile.cpf,
        email: updatedProfile.email,
        telefone: updatedProfile.telefone,
        dataNascimento: updatedProfile.dataNascimento,
        metodoAutenticacao:
            updatedProfile.metodoAutenticacao == AuthMethod.google
            ? 'google'
            : 'email',
      );

      when(
        () => mockProfileApiClient.getProfile(),
      ).thenAnswer((_) async => Success(updatedProfileApi));

      await profileRepository.updateBirthdate(newDate);

      final result = await profileRepository.getProfile();

      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess()?.dataNascimento, newDate);
    });
  });

  group("Change Phone number", () {
    setUp(() {
      when(
        () => mockProfileApiClient.updatePhone(any()),
      ).thenAnswer((_) async => const Success('11988888888'));
    });

    test("it returns success from ApiClient", () async {
      final result = await profileRepository.updatePhone('11988888888');
      expect(result.isSuccess(), true);
    });

    test("it returns error from ApiClient", () async {
      when(
        () => mockProfileApiClient.updatePhone(any()),
      ).thenAnswer((_) async => Error(Exception('Network error')));

      final result = await profileRepository.updatePhone('11988888888');
      expect(result.isError(), true);
    });
    test("it refreshes cache after update", () async {
      await profileRepository.getProfile();

      final updatedProfile = fakeProfile.copyWith(telefone: '11988888888');
      final updatedProfileApi = ProfileApiModel(
        id: updatedProfile.id,
        nome: updatedProfile.nome,
        cpf: updatedProfile.cpf,
        email: updatedProfile.email,
        telefone: updatedProfile.telefone,
        dataNascimento: updatedProfile.dataNascimento,
        metodoAutenticacao:
            updatedProfile.metodoAutenticacao == AuthMethod.google
            ? 'google'
            : 'email',
      );

      when(
        () => mockProfileApiClient.getProfile(),
      ).thenAnswer((_) async => Success(updatedProfileApi));

      await profileRepository.updatePhone('11988888888');

      final result = await profileRepository.getProfile();

      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess()?.telefone, '11988888888');
    });
  });

  group("Delete Account", () {
    setUp(() {
      when(
        () => mockProfileApiClient.deleteAccount(),
      ).thenAnswer((_) async => const Success(null));
    });

    test("it returns success from ApiClient", () async {
      final result = await profileRepository.deleteAccount();
      expect(result.isSuccess(), true);
    });

    test("it returns error from ApiClient", () async {
      when(
        () => mockProfileApiClient.deleteAccount(),
      ).thenAnswer((_) async => Error(Exception('Network error')));

      final result = await profileRepository.deleteAccount();
      expect(result.isError(), true);
    });

    test("it clears cache after deletion", () async {
      final initialResult = await profileRepository.getProfile();
      expect(initialResult.isSuccess(), true);

      await profileRepository.deleteAccount();

      when(
        () => mockProfileApiClient.getProfile(),
      ).thenAnswer((_) async => Error(Exception('User not found')));

      final result = await profileRepository.getProfile();

      expect(result.isError(), true);
    });
  });

  group("Request Phone Verification Code", () {
    setUp(() {
      when(
        () => mockProfileApiClient.requestPhoneVerificationCode(any()),
      ).thenAnswer((_) async => const Success(null));
    });

    test("it returns success from ApiClient", () async {
      final result = await profileRepository.requestPhoneVerificationCode(
        '11999999999',
      );
      expect(result.isSuccess(), true);
    });

    test("it returns error from ApiClient", () async {
      when(
        () => mockProfileApiClient.requestPhoneVerificationCode(any()),
      ).thenAnswer((_) async => Error(Exception('Network error')));

      final result = await profileRepository.requestPhoneVerificationCode(
        '11999999999',
      );
      expect(result.isError(), true);
    });
  });

  group("Verify Phone Code", () {
    setUp(() {
      when(
        () => mockProfileApiClient.verifyPhoneCode(any()),
      ).thenAnswer((_) async => const Success(null));
    });

    test("it returns success from ApiClient", () async {
      final result = await profileRepository.verifyPhoneCode('123456');
      expect(result.isSuccess(), true);
    });

    test("it returns error from ApiClient", () async {
      when(
        () => mockProfileApiClient.verifyPhoneCode(any()),
      ).thenAnswer((_) async => Error(Exception('Invalid code')));

      final result = await profileRepository.verifyPhoneCode('123456');
      expect(result.isError(), true);
    });
  });

  group("Link Google Account", () {
    setUp(() {
      when(
        () => mockProfileApiClient.linkGoogleAccount(any()),
      ).thenAnswer((_) async => const Success(null));
    });

    test("it returns success from ApiClient", () async {
      final result = await profileRepository.linkGoogleAccount('valid_token');
      expect(result.isSuccess(), true);
    });

    test("it returns error from ApiClient", () async {
      when(
        () => mockProfileApiClient.linkGoogleAccount(any()),
      ).thenAnswer((_) async => Error(Exception('Invalid token')));

      final result = await profileRepository.linkGoogleAccount('invalid_token');
      expect(result.isError(), true);
    });
  });

  group("Request Data Export", () {
    setUp(() {
      when(
        () => mockProfileApiClient.requestDataExport(),
      ).thenAnswer((_) async => const Success(null));
    });

    test("it returns success from ApiClient", () async {
      final result = await profileRepository.requestDataExport();
      expect(result.isSuccess(), true);
      verify(() => mockProfileApiClient.requestDataExport()).called(1);
    });

    test("it returns error from ApiClient", () async {
      when(
        () => mockProfileApiClient.requestDataExport(),
      ).thenAnswer((_) async => Error(Exception('Export failed')));

      final result = await profileRepository.requestDataExport();
      expect(result.isError(), true);
    });
  });
}
