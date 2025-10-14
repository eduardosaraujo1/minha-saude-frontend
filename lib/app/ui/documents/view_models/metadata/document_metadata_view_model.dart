import 'package:command_it/command_it.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../data/repositories/document/document_repository.dart';
import '../../../../domain/models/document/document.dart';

class DocumentMetadataViewModel {
  DocumentMetadataViewModel({
    required String documentUuid,
    required DocumentRepository documentRepository,
  }) : _documentRepository = documentRepository,
       _documentUuid = documentUuid {
    loadDocument = Command.createAsyncNoParam(
      _loadDocument,
      initialValue: null,
    );
  }

  final DocumentRepository _documentRepository;
  final String _documentUuid;
  final Logger _log = Logger("DocumentMetadataViewModel");

  late final Command<void, Result<Document, Exception>?> loadDocument;

  Future<Result<Document, Exception>> _loadDocument() async {
    try {
      final documentResult = await _documentRepository.getDocumentMeta(
        _documentUuid,
      );

      if (documentResult.isError()) {
        final error = documentResult.tryGetError()!;

        _log.severe("Failed to load document metadata", error);
        return Error(Exception("Falha ao carregar metadados do documento"));
      }

      final document = documentResult.tryGetSuccess()!;

      return Success(document);
    } catch (e) {
      _log.severe("Failed to load document metadata", e);
      return Error(Exception("Falha ao carregar metadados do documento"));
    }
  }
}
