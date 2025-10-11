import '../http_client.dart';
import 'profile_api_client.dart';

class ProfileApiClientImpl extends ProfileApiClient {
  ProfileApiClientImpl(this.httpClient);

  final HttpClient httpClient;
}
