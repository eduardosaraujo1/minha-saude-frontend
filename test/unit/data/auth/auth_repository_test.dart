import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/services/api/auth/auth_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/google/google_service.dart';
import 'package:minha_saude_frontend/app/data/services/secure_storage/secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAuthApiClient extends Mock implements AuthApiClient {}

class MockGoogleService extends Mock implements GoogleService {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late AuthApiClient authApiClient;
  late GoogleService googleService;
  late AuthRepository authRepository;

  setUp(() {
    authApiClient = MockAuthApiClient();
    googleService = MockGoogleService();

    authRepository = AuthRepositoryImpl(
      apiClient: authApiClient,
      googleService: googleService,
    );
  });

  group("AuthRepository", () {
    test("should return a user when login is successful", () async {
      // TODO
    });
  });
}
