import 'package:minha_saude_frontend/app/data/repositories/document/document_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/document/document_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/services/api/profile/profile_api_client.dart';
import 'package:mocktail/mocktail.dart';
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
  test(
    "when export data is called, correspoding service method must be invoked",
    () {
      //
    },
  );
}
