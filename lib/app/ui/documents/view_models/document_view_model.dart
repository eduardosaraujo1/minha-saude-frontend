import 'dart:io';

import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../view_model.dart';
import '../../../data/repositories/document/document_repository.dart';
import '../../../domain/models/document/document.dart';

class DocumentViewModel implements ViewModel {
  DocumentViewModel({
    required String documentUuid,
    required DocumentRepository documentRepository,
  }) : _documentUuid = documentUuid,
       _documentRepository = documentRepository {
    loadDocument = Command.createAsyncNoParam(
      _loadDocument,
      initialValue: null,
    );
    deleteDocument = Command.createAsync(
      _handleDeleteDocument,
      initialValue: null,
    );
  }

  final String _documentUuid;
  final DocumentRepository _documentRepository;
  final Logger _logger = Logger('DocumentViewModel');

  String get documentUuid => _documentUuid;

  late final Command<void, Result<DocumentWithFile, Exception>?> loadDocument;
  late final Command<Document, Result<void, Exception>?> deleteDocument;

  final ValueNotifier<int> currentPage = ValueNotifier<int>(-1);
  final ValueNotifier<int> totalPages = ValueNotifier<int>(-1);

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

  Future<Result<void, Exception>> _handleDeleteDocument(Document doc) async {
    try {
      final result = await _documentRepository.moveToTrash(doc.uuid);
      if (result.isError()) {
        _logger.severe('Error deleting document: ${result.tryGetError()}');
        return Result.error(Exception("Não foi possível excluir o documento."));
      }

      return Result.success(null);
    } catch (e) {
      _logger.severe('Error deleting document', e);
      return Result.error(Exception("Não foi possível excluir o documento."));
    }
  }

  void triggerDocumentDelete() {
    if (loadDocument.value != null && loadDocument.value!.isSuccess()) {
      final doc = loadDocument.value!.getOrThrow().document;
      deleteDocument.execute(doc);
    }
  }

  @override
  void dispose() {
    currentPage.dispose();
    totalPages.dispose();
    loadDocument.dispose();
    deleteDocument.dispose();
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
