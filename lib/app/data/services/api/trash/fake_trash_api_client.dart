import 'package:minha_saude_frontend/app/data/services/api/fakes/fake_document_server_storage.dart';

import 'trash_api_client.dart';

class FakeTrashApiClient extends TrashApiClient {
  FakeTrashApiClient({required this.serverStorage});

  final FakeDocumentServerStorage serverStorage;
}
