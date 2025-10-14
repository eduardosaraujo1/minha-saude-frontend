import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/services/api/profile/models/profile_api_model.dart';
import 'package:minha_saude_frontend/app/data/services/api/profile/profile_api_client.dart';
import 'package:minha_saude_frontend/app/domain/models/profile/profile.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

class MockProfileApiClient extends Mock implements ProfileApiClient {}

void main() {
  late ProfileApiClient mockProfileApiClient;
  late ProfileRepository profileRepository;
  setUp(() {
    mockProfileApiClient = MockProfileApiClient();
    profileRepository = ProfileRepositoryImpl(
      profileApiClient: mockProfileApiClient,
    );
  });

  group("getProfile", () {
    test(
      "when getProfile is ran, result is the same as the ApiClient",
      () async {
        // Mock apiclient to respond success
        final fakeProfile = ProfileApiModel(
          id: '12345',
          nome: 'João Silva',
          cpf: '123.456.789-00',
          email: 'joao.silva@example.com',
          telefone: '11999999999',
          dataNascimento: DateTime(1990, 1, 1),
          metodoAutenticacao: 'email',
        );
        final fakeProfileModel = Profile(
          id: fakeProfile.id,
          nome: fakeProfile.nome,
          cpf: fakeProfile.cpf,
          email: fakeProfile.email,
          telefone: fakeProfile.telefone,
          dataNascimento: fakeProfile.dataNascimento,
          metodoAutenticacao: switch (fakeProfile.metodoAutenticacao) {
            'email' => AuthMethod.email,
            'google' => AuthMethod.google,
            _ => AuthMethod.email,
          },
        );
        when(
          () => mockProfileApiClient.getProfile(),
        ).thenAnswer((_) async => Success(fakeProfile));

        // Call repository
        final result = await profileRepository.getProfile();

        // Verify response matches
        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), fakeProfileModel);
      },
    );
    test(
      "when getProfile is ran twice, ApiClient is only called once (caching)",
      () async {
        // Mock apiclient to respond success
        final fakeProfile = ProfileApiModel(
          id: '12345',
          nome: 'João Silva',
          cpf: '123.456.789-00',
          email: 'joao.silva@example.com',
          telefone: '11999999999',
          dataNascimento: DateTime(1990, 1, 1),
          metodoAutenticacao: 'email',
        );
        when(
          () => mockProfileApiClient.getProfile(),
        ).thenAnswer((_) async => Success(fakeProfile));

        // Call repository getProfile (store response 1)
        final result1 = await profileRepository.getProfile();

        // Mock apiclient to respond error
        when(
          () => mockProfileApiClient.getProfile(),
        ).thenAnswer((_) async => Error(Exception('Network error')));

        // Call repository getProfile again (store response 2)
        final result2 = await profileRepository.getProfile();

        final expectedProfile = Profile(
          id: fakeProfile.id,
          nome: fakeProfile.nome,
          cpf: fakeProfile.cpf,
          email: fakeProfile.email,
          telefone: fakeProfile.telefone,
          dataNascimento: fakeProfile.dataNascimento,
          metodoAutenticacao: AuthMethod.email,
        );

        // Assert response 1 is success
        expect(result1.isSuccess(), true);
        expect(result1.tryGetSuccess(), expectedProfile);

        // Assert response 2 is same success
        expect(result2.isSuccess(), true);
        expect(result2.tryGetSuccess(), expectedProfile);

        // Verify API was only called once
        verify(() => mockProfileApiClient.getProfile()).called(1);
      },
    );

    test(
      "if forceRefresh parameter is passed when getProfile is ran the second time, ApiClient is called again (no caching)",
      () async {
        // Mock apiclient to respond success (mock1)
        final fakeProfile1 = ProfileApiModel(
          id: '12345',
          nome: 'João Silva',
          cpf: '123.456.789-00',
          email: 'joao.silva@example.com',
          telefone: '11999999999',
          dataNascimento: DateTime(1990, 1, 1),
          metodoAutenticacao: 'email',
        );
        when(
          () => mockProfileApiClient.getProfile(),
        ).thenAnswer((_) async => Success(fakeProfile1));

        // Call repository getProfile (store response 1)
        final result1 = await profileRepository.getProfile();

        // Mock apiclient to respond success with different data (mock2)
        final fakeProfile2 = ProfileApiModel(
          id: '12345',
          nome: 'Maria Santos',
          cpf: '123.456.789-00',
          email: 'joao.silva@example.com',
          telefone: '11988888888',
          dataNascimento: DateTime(1990, 1, 1),
          metodoAutenticacao: 'email',
        );
        when(
          () => mockProfileApiClient.getProfile(),
        ).thenAnswer((_) async => Success(fakeProfile2));

        // Call repository getProfile again (store response 2)
        final result2 = await profileRepository.getProfile(forceRefresh: true);

        final expectedProfile1 = Profile(
          id: fakeProfile1.id,
          nome: fakeProfile1.nome,
          cpf: fakeProfile1.cpf,
          email: fakeProfile1.email,
          telefone: fakeProfile1.telefone,
          dataNascimento: fakeProfile1.dataNascimento,
          metodoAutenticacao: AuthMethod.email,
        );

        final expectedProfile2 = Profile(
          id: fakeProfile2.id,
          nome: fakeProfile2.nome,
          cpf: fakeProfile2.cpf,
          email: fakeProfile2.email,
          telefone: fakeProfile2.telefone,
          dataNascimento: fakeProfile2.dataNascimento,
          metodoAutenticacao: AuthMethod.email,
        );

        // Assert response 1 is mock1 success
        expect(result1.isSuccess(), true);
        expect(result1.tryGetSuccess(), expectedProfile1);

        // Assert response 2 is mock2 success
        expect(result2.isSuccess(), true);
        expect(result2.tryGetSuccess(), expectedProfile2);

        // Verify API was called twice
        verify(() => mockProfileApiClient.getProfile()).called(2);
      },
    );
  });

  group("updateName", () {
    test("when method is ran, result is the same as the ApiClient", () async {
      // Mock apiclient to respond success
      when(
        () => mockProfileApiClient.updateName(any()),
      ).thenAnswer((_) async => const Success('João Silva'));

      // Call repository
      final result1 = await profileRepository.updateName('João Silva');

      // Verify response matches
      expect(result1.isSuccess(), true);

      // Mock apiclient to respond error
      when(
        () => mockProfileApiClient.updateName(any()),
      ).thenAnswer((_) async => Error(Exception('Network error')));

      // Call repository again
      final result2 = await profileRepository.updateName('Maria Santos');

      // Verify response matches
      expect(result2.isError(), true);
    });
    test("when method is ran, cache is updated with API response", () async {
      // Mock apiclient to respond success with name X
      final initialProfile = ProfileApiModel(
        id: '12345',
        nome: 'João Silva',
        cpf: '123.456.789-00',
        email: 'joao.silva@example.com',
        telefone: '11999999999',
        dataNascimento: DateTime(1990, 1, 1),
        metodoAutenticacao: 'email',
      );
      when(
        () => mockProfileApiClient.getProfile(),
      ).thenAnswer((_) async => Success(initialProfile));

      // Load initial cache
      await profileRepository.getProfile();

      // Call repository to update name to Y
      final updatedProfile = ProfileApiModel(
        id: '12345',
        nome: 'Maria Santos',
        cpf: '123.456.789-00',
        email: 'joao.silva@example.com',
        telefone: '11999999999',
        dataNascimento: DateTime(1990, 1, 1),
        metodoAutenticacao: 'email',
      );
      when(
        () => mockProfileApiClient.updateName('Maria Santos'),
      ).thenAnswer((_) async => const Success('Maria Santos'));
      when(
        () => mockProfileApiClient.getProfile(),
      ).thenAnswer((_) async => Success(updatedProfile));

      await profileRepository.updateName('Maria Santos');

      // call getProfile
      final result = await profileRepository.getProfile();

      // Verify edited value matches server (Y) and not locally sent value (X)
      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess()?.nome, 'Maria Santos');
    });
  });

  group("updateBirthdate", () {
    test("when method is ran, result is the same as the ApiClient", () async {
      // Mock apiclient to respond success
      when(
        () => mockProfileApiClient.updateBirthdate(any()),
      ).thenAnswer((_) async => const Success('1990-01-01'));

      // Call repository
      final result1 = await profileRepository.updateBirthdate(
        DateTime(1990, 1, 1),
      );

      // Verify response matches
      expect(result1.isSuccess(), true);

      // Mock apiclient to respond error
      when(
        () => mockProfileApiClient.updateBirthdate(any()),
      ).thenAnswer((_) async => Error(Exception('Network error')));

      // Call repository again
      final result2 = await profileRepository.updateBirthdate(
        DateTime(1995, 5, 5),
      );

      // Verify response matches
      expect(result2.isError(), true);
    });
    test("when method is ran, cache is updated with API response", () async {
      // Mock apiclient to respond success with date X
      final initialProfile = ProfileApiModel(
        id: '12345',
        nome: 'João Silva',
        cpf: '123.456.789-00',
        email: 'joao.silva@example.com',
        telefone: '11999999999',
        dataNascimento: DateTime(1990, 1, 1),
        metodoAutenticacao: 'email',
      );
      when(
        () => mockProfileApiClient.getProfile(),
      ).thenAnswer((_) async => Success(initialProfile));

      // Load initial cache
      await profileRepository.getProfile();

      // Call repository to update date to Y
      final newDate = DateTime(1995, 5, 5);
      final updatedProfile = ProfileApiModel(
        id: '12345',
        nome: 'João Silva',
        cpf: '123.456.789-00',
        email: 'joao.silva@example.com',
        telefone: '11999999999',
        dataNascimento: newDate,
        metodoAutenticacao: 'email',
      );
      when(
        () => mockProfileApiClient.updateBirthdate(newDate),
      ).thenAnswer((_) async => const Success('1995-05-05'));
      when(
        () => mockProfileApiClient.getProfile(),
      ).thenAnswer((_) async => Success(updatedProfile));

      await profileRepository.updateBirthdate(newDate);

      // call getProfile
      final result = await profileRepository.getProfile();

      // Verify edited value matches server (Y) and not locally sent value (X)
      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess()?.dataNascimento, newDate);
    });
  });

  group("updatePhone", () {
    test(
      "when updatePhone is ran, result is the same as the ApiClient",
      () async {
        // Mock apiclient to respond success
        when(
          () => mockProfileApiClient.updatePhone(any()),
        ).thenAnswer((_) async => const Success('11999999999'));

        // Call repository
        final result1 = await profileRepository.updatePhone('11999999999');

        // Verify response matches
        expect(result1.isSuccess(), true);

        // Mock apiclient to respond error
        when(
          () => mockProfileApiClient.updatePhone(any()),
        ).thenAnswer((_) async => Error(Exception('Network error')));

        // Call repository again
        final result2 = await profileRepository.updatePhone('11988888888');

        // Verify response matches
        expect(result2.isError(), true);
      },
    );
    test(
      "when updatePhone is ran, cache is updated with API response",
      () async {
        // Mock apiclient to respond success with phone X
        final initialProfile = ProfileApiModel(
          id: '12345',
          nome: 'João Silva',
          cpf: '123.456.789-00',
          email: 'joao.silva@example.com',
          telefone: '11999999999',
          dataNascimento: DateTime(1990, 1, 1),
          metodoAutenticacao: 'email',
        );
        when(
          () => mockProfileApiClient.getProfile(),
        ).thenAnswer((_) async => Success(initialProfile));

        // Load initial cache
        await profileRepository.getProfile();

        // Call repository to update phone to Y
        final updatedProfile = ProfileApiModel(
          id: '12345',
          nome: 'João Silva',
          cpf: '123.456.789-00',
          email: 'joao.silva@example.com',
          telefone: '11988888888',
          dataNascimento: DateTime(1990, 1, 1),
          metodoAutenticacao: 'email',
        );
        when(
          () => mockProfileApiClient.updatePhone('11988888888'),
        ).thenAnswer((_) async => const Success('11988888888'));
        when(
          () => mockProfileApiClient.getProfile(),
        ).thenAnswer((_) async => Success(updatedProfile));

        await profileRepository.updatePhone('11988888888');

        // call getProfile
        final result = await profileRepository.getProfile();

        // Verify edited value matches server (Y) and not locally sent value (X)
        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess()?.telefone, '11988888888');
      },
    );
  });

  group("deleteAccount", () {
    test(
      "when deleteAccount is ran, result is the same as the ApiClient",
      () async {
        // Mock apiclient to respond success
        when(
          () => mockProfileApiClient.deleteAccount(),
        ).thenAnswer((_) async => const Success(null));

        // Call repository
        final result1 = await profileRepository.deleteAccount();

        // Verify response matches
        expect(result1.isSuccess(), true);

        // Mock apiclient to respond error
        when(
          () => mockProfileApiClient.deleteAccount(),
        ).thenAnswer((_) async => Error(Exception('Network error')));

        // Call repository again
        final result2 = await profileRepository.deleteAccount();

        // Verify response matches
        expect(result2.isError(), true);
      },
    );
    test(
      "When deleteAccount is run getProfile must return error (cache clear)",
      () async {
        // mock apiclient to return success on getProfile
        final fakeProfile = ProfileApiModel(
          id: '12345',
          nome: 'João Silva',
          cpf: '123.456.789-00',
          email: 'joao.silva@example.com',
          telefone: '11999999999',
          dataNascimento: DateTime(1990, 1, 1),
          metodoAutenticacao: 'email',
        );
        when(
          () => mockProfileApiClient.getProfile(),
        ).thenAnswer((_) async => Success(fakeProfile));

        // mock apiclient to return success on deleteAccount
        when(
          () => mockProfileApiClient.deleteAccount(),
        ).thenAnswer((_) async => const Success(null));

        // call getProfile on repository (stores cache)
        final initialResult = await profileRepository.getProfile();
        expect(initialResult.isSuccess(), true);

        // call deleteAccount on repository
        await profileRepository.deleteAccount();

        // mock apiclient to return error on getProfile
        when(
          () => mockProfileApiClient.getProfile(),
        ).thenAnswer((_) async => Error(Exception('User not found')));

        // call getProfile on repository
        final result = await profileRepository.getProfile();

        // assert return error, not cached value
        expect(result.isError(), true);
      },
    );
  });

  test(
    "when requestPhoneVerificationCode function is called then response must match ApiClient",
    () async {
      // Mock apiclient to respond success
      when(
        () => mockProfileApiClient.requestPhoneVerificationCode(any()),
      ).thenAnswer((_) async => const Success(null));

      // Call repository
      final result1 = await profileRepository.requestPhoneVerificationCode(
        '11999999999',
      );

      // Verify response matches
      expect(result1.isSuccess(), true);

      // Mock apiclient to respond error
      when(
        () => mockProfileApiClient.requestPhoneVerificationCode(any()),
      ).thenAnswer((_) async => Error(Exception('Network error')));

      // Call repository again
      final result2 = await profileRepository.requestPhoneVerificationCode(
        '11988888888',
      );

      // Verify response matches
      expect(result2.isError(), true);
    },
  );

  test(
    "when verifyPhoneCode function is called then response must match ApiClient",
    () async {
      // Mock apiclient to respond success
      when(
        () => mockProfileApiClient.verifyPhoneCode(any()),
      ).thenAnswer((_) async => const Success(null));

      // Call repository
      final result1 = await profileRepository.verifyPhoneCode('123456');

      // Verify response matches
      expect(result1.isSuccess(), true);

      // Mock apiclient to respond error
      when(
        () => mockProfileApiClient.verifyPhoneCode(any()),
      ).thenAnswer((_) async => Error(Exception('Invalid code')));

      // Call repository again
      final result2 = await profileRepository.verifyPhoneCode('000000');

      // Verify response matches
      expect(result2.isError(), true);
    },
  );

  test(
    "if token is valid when linkGoogleAccount is ran then response must match ApiModel",
    () async {
      // Mock apiclient to respond success
      when(
        () => mockProfileApiClient.linkGoogleAccount(any()),
      ).thenAnswer((_) async => const Success(null));

      // Call repository
      final result1 = await profileRepository.linkGoogleAccount('valid_token');

      // Verify response matches
      expect(result1.isSuccess(), true);

      // Mock apiclient to respond error
      when(
        () => mockProfileApiClient.linkGoogleAccount(any()),
      ).thenAnswer((_) async => Error(Exception('Invalid token')));

      // Call repository again
      final result2 = await profileRepository.linkGoogleAccount(
        'invalid_token',
      );

      // Verify response matches
      expect(result2.isError(), true);
    },
  );

  test(
    "when export data is called, correspoding ApiClient method must be invoked and response must match ApiClient",
    () async {
      // Mock apiclient to respond success
      when(
        () => mockProfileApiClient.requestDataExport(),
      ).thenAnswer((_) async => const Success(null));

      // Call repository
      final result1 = await profileRepository.requestDataExport();

      // Verify response matches
      expect(result1.isSuccess(), true);
      verify(() => mockProfileApiClient.requestDataExport()).called(1);

      // Mock apiclient to respond error
      when(
        () => mockProfileApiClient.requestDataExport(),
      ).thenAnswer((_) async => Error(Exception('Export failed')));

      // Call repository again
      final result2 = await profileRepository.requestDataExport();

      // Verify response matches
      expect(result2.isError(), true);
      verify(() => mockProfileApiClient.requestDataExport()).called(1);
    },
  );
}
