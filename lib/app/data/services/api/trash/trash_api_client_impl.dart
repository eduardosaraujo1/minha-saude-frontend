import '../http_client.dart';

import 'trash_api_client.dart';

class TrashApiClientImpl extends TrashApiClient {
  TrashApiClientImpl({required this.httpClient});

  final HttpClient httpClient;
}
