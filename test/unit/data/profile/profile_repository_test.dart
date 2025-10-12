import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/services/api/profile/models/profile_api_model.dart';
import 'package:minha_saude_frontend/app/data/services/api/profile/profile_api_client.dart';
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
        when(
          () => mockProfileApiClient.getProfile(),
        ).thenAnswer((_) async => Success(fakeProfile));

        // Call repository
        final result = await profileRepository.getProfile();

        // Verify response matches
        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), fakeProfile);
      },
    );
    test(
      "when getProfile is ran twice, ApiClient is only called once (caching)",
      () async {
        // Mock apiclient to respond success

        // Call repository getProfile (store response 1)

        // Mock apiclient to respond error

        // Call repository getProfile again (store response 2)

        // Assert response 1 is success
        // Assert response 2 is same success
      },
    );

    test(
      "if forceRefresh parameter is passed when getProfile is ran the second time, ApiClient is called again (no caching)",
      () async {
        // Mock apiclient to respond success (mock1)

        // Call repository getProfile (store response 1)

        // Mock apiclient to respond success with different data (mock2)

        // Call repository getProfile again (store response 2)

        // Assert response 1 is mock1 success
        // Assert response 2 is mock2 success
      },
    );
  });

  group("updateName", () {
    test("when method is ran, result is the same as the ApiClient", () async {
      // Mock apiclient to respond success

      // Call repository

      // Verify response matches

      // Mock apiclient to respond error

      // Call repository again

      // Verify response matches
    });
    test("when method is ran, cache is updated with API response", () async {
      // Mock apiclient to respond success with name X

      // Call repository to update name to Y

      // call getProfile

      // Verify edited value matches server (Y) and not locally sent value (X)
    });
  });

  group("updateBirthdate", () {
    test("when method is ran, result is the same as the ApiClient", () async {
      // Mock apiclient to respond success

      // Call repository

      // Verify response matches

      // Mock apiclient to respond error

      // Call repository again

      // Verify response matches
    });
    test("when method is ran, cache is updated with API response", () async {
      // Mock apiclient to respond success with date X

      // Call repository to update date to Y

      // call getProfile

      // Verify edited value matches server (Y) and not locally sent value (X)
    });
  });

  group("updatePhone", () {
    test(
      "when updatePhone is ran, result is the same as the ApiClient",
      () async {
        // Mock apiclient to respond success

        // Call repository

        // Verify response matches

        // Mock apiclient to respond error

        // Call repository again

        // Verify response matches
      },
    );
    test(
      "when updatePhone is ran, cache is updated with API response",
      () async {
        // Mock apiclient to respond success with phone X

        // Call repository to update phone to Y

        // call getProfile

        // Verify edited value matches server (Y) and not locally sent value (X)
      },
    );
  });

  group("deleteAccount", () {
    test(
      "when deleteAccount is ran, result is the same as the ApiClient",
      () async {
        // Mock apiclient to respond success

        // Call repository

        // Verify response matches

        // Mock apiclient to respond error

        // Call repository again

        // Verify response matches
      },
    );
    test(
      "When deleteAccount is run getProfile must return error (cache clear)",
      () async {
        // mock apiclient to return success on getProfile
        // mock apiclient to return success on deleteAccount

        // call getProfile on repository (stores cache)
        // call deleteAccount on repository

        // mock apiclient to return error on getProfile

        // call getProfile on repository
        // assert return error, not cached value
      },
    );
  });

  test(
    "when requestPhoneVerificationCode function is called then response must match ApiClient",
    () async {
      // Mock apiclient to respond success

      // Call repository

      // Verify response matches

      // Mock apiclient to respond error

      // Call repository again

      // Verify response matches
    },
  );

  test(
    "when verifyPhoneCode function is called then response must match ApiClient",
    () async {
      // Mock apiclient to respond success

      // Call repository

      // Verify response matches

      // Mock apiclient to respond error

      // Call repository again

      // Verify response matches
    },
  );

  test(
    "if token is valid when linkGoogleAccount is ran then response must match ApiModel",
    () async {
      // Mock apiclient to respond success

      // Call repository

      // Verify response matches

      // Mock apiclient to respond error

      // Call repository again

      // Verify response matches
    },
  );

  test(
    "when export data is called, correspoding ApiClient method must be invoked and response must match ApiClient",
    () {
      //
    },
  );
}
