import '../../../../data/repositories/document/document_repository.dart';

class DocumentEditViewModel {
  DocumentEditViewModel({
    required this.documentUuid,
    required this.documentRepository,
  });

  final String documentUuid;
  final DocumentRepository documentRepository;
}
