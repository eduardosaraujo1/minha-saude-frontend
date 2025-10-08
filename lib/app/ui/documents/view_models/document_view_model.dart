import 'dart:io';

import 'package:command_it/command_it.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../data/repositories/document/document_repository.dart';
import '../../../domain/models/document/document.dart';

class DocumentViewModel {
  DocumentViewModel({
    required String documentUuid,
    required DocumentRepository documentRepository,
  }) : _documentUuid = documentUuid,
       _documentRepository = documentRepository {
    loadDocument =
        Command.createAsyncNoParam<Result<DocumentWithFile?, Exception>>(
          _loadDocument,
          initialValue: Success(null),
        );
    loadDocument.execute();
  }

  final String _documentUuid;
  final DocumentRepository _documentRepository;
  final Logger _logger = Logger('DocumentViewModel');

  late final Command<void, Result<DocumentWithFile?, Exception>> loadDocument;

  Future<Result<DocumentWithFile, Exception>> _loadDocument() async {
    try {
      // Load metadata
      final documentMetadata = await _documentRepository.getDocumentMeta(
        _documentUuid,
      );
      if (documentMetadata.isError()) {
        final error = documentMetadata.tryGetError();
        _logger.severe('Error loading document metadata', error);
        return Result.error(
          Exception("Não foi possível carregar o documento."),
        );
      }

      // Load file
      final documentFile = await _documentRepository.getDocumentFile(
        _documentUuid,
      );
      if (documentFile.isError()) {
        final error = documentFile.tryGetError();
        _logger.severe('Error loading document file', error);
        return Result.error(
          Exception("Não foi possível carregar o documento."),
        );
      }

      final document = DocumentWithFile(
        document: documentMetadata.getOrThrow(),
        file: documentFile.getOrThrow(),
      );

      return Result.success(document);
    } catch (e) {
      _logger.severe('Exception loading document:', e);
      return Result.error(
        Exception("Ocorreu um erro desconhecido ao carregar o documento."),
      );
    }
  }
}

class DocumentWithFile {
  const DocumentWithFile({required Document document, required File file})
    : _document = document,
      _file = file;

  final Document _document;
  final File _file;

  Document get document => _document;
  File get file => _file;
}

enum DocumentAction { view, edit, delete }

enum DocumentLoadStatus { loading, loaded, error }
