import '../../services/api/profile/profile_api_client.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  ProfileRepositoryImpl({
    required this.profileApiClient, //
  });

  final ProfileApiClient profileApiClient;
}
