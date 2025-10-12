import '../../services/api/trash/trash_api_client.dart';
import 'trash_repository.dart';

class TrashRepositoryImpl extends TrashRepository {
  TrashRepositoryImpl({required this.trashApiClient});

  final TrashApiClient trashApiClient;
  //
}

// TODO: Write local cache management class if necessary
