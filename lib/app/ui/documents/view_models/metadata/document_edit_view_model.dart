import 'package:command_it/command_it.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../data/repositories/document/document_repository.dart';
import '../../../../domain/models/document/document.dart';

class DocumentEditViewModel {
  DocumentEditViewModel({
    required this.documentUuid,
    required this.documentRepository,
  }) {
    loadDocument = Command.createAsyncNoParam(
      _loadDocument,
      initialValue: null,
    );
    updateDocument = Command.createAsync(_updateDocument, initialValue: null);
  }

  final String documentUuid;
  final DocumentRepository documentRepository;
  final Logger _log = Logger('document_edit_view_model');

  late final Command<void, Result<Document, Exception>?> loadDocument;
  late final Command<DocumentUploadModel, Result<Document, Exception>?>
  updateDocument;

  Future<Result<Document, Exception>> _loadDocument() async {
    try {
      final document = await documentRepository.getDocumentMeta(documentUuid);

      // Load command
      if (document.isError()) {
        final error = document.tryGetError()!;
        _log.severe("Error loading document: $error");
        return Result.error(Exception("Erro ao carregar documento."));
      }

      return Result.success(document.tryGetSuccess()!);
    } catch (e, s) {
      _log.severe("Failed to load document", e, s);
      return Result.error(Exception("Erro ao carregar documento."));
    }
  }

  Future<Result<Document, Exception>> _updateDocument(
    DocumentUploadModel doc,
  ) async {
    try {
      final result = await documentRepository.updateDocument(
        documentUuid,
        titulo: doc.titulo,
        dataDocumento: doc.dataDocumento,
        medico: doc.medico,
        paciente: doc.paciente,
        tipo: doc.tipo,
      );

      if (result.isError()) {
        final error = result.tryGetError()!;
        _log.severe("Error updating document: $error");
        return Result.error(Exception("Erro ao atualizar documento."));
      }

      return Result.success(result.tryGetSuccess()!);
    } catch (e, s) {
      _log.severe("Failed to update document", e, s);
      return Result.error(Exception("Erro ao atualizar documento."));
    }
  }
}

class DocumentUploadModel {
  final String titulo;
  final DateTime? dataDocumento;
  final String? medico;
  final String? paciente;
  final String? tipo;

  DocumentUploadModel({
    required this.titulo,
    this.dataDocumento,
    this.medico,
    this.paciente,
    this.tipo,
  });
}
