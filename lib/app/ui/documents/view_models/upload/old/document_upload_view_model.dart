// import 'dart:io';

// import 'package:command_it/command_it.dart';
// import 'package:flutter/material.dart';
// import 'package:logging/logging.dart';
// import 'package:multiple_result/multiple_result.dart';

// import '../../../../data/repositories/document/document_repository.dart';
// import '../../../../domain/models/document/document.dart';
// import 'document_info_form_model.dart';

// class DocumentUploadViewModel {
//   DocumentUploadViewModel(this._type, this._documentRepository) {
//     loadDocument = Command.createAsyncNoParam(
//       _loadDocument,
//       initialValue: null,
//     );
//     uploadDocument = Command.createAsync(_uploadDocument, initialValue: null);
//   }

//   final DocumentRepository _documentRepository;
//   final DocumentUploadMethod _type;
//   final Logger _logger = Logger('DocumentUploadViewModel');

//   final currentStep = ValueNotifier<UploadStep>(UploadStep.preview);

//   late final Command<void, Result<File, Exception>?> loadDocument;
//   late final Command<DocumentFormData, Result<Document?, Exception>?>
//   uploadDocument;

//   Future<Result<File, Exception>> _loadDocument() async {
//     try {
//       final result = switch (_type) {
//         DocumentUploadMethod.scan =>
//           await _documentRepository.scanDocumentFile(),
//         DocumentUploadMethod.upload =>
//           await _documentRepository.pickDocumentFile(),
//       };

//       if (result.isError()) {
//         _logger.severe('Error loading document: ${result.tryGetError()}');
//         return Result.error(
//           Exception("Não foi possível carregar o documento."),
//         );
//       }

//       return Result.success(result.getOrThrow());
//     } catch (e, s) {
//       _logger.severe('Exception loading document:', e, s);
//       return Result.error(
//         Exception("Ocorreu um erro desconhecido ao carregar o documento."),
//       );
//     }
//   }

//   Future<Result<Document, Exception>> _uploadDocument(
//     DocumentFormData formData,
//   ) async {
//     final document = loadDocument.value;

//     if (document == null || document.isError()) {
//       _logger.severe('No file uploaded when trying to upload document.');
//       return Result.error(Exception("Nenhum arquivo foi carregado."));
//     }

//     try {
//       final result = await _documentRepository.uploadDocument(
//         document.getOrThrow(),
//         paciente: formData.nomePaciente ?? '',
//         titulo: formData.titulo,
//         tipo: formData.tipoDocumento,
//         medico: formData.nomeMedico,
//         dataDocumento: formData.dataDocumento,
//       );

//       if (result.isError()) {
//         _logger.severe('Error uploading document: ${result.tryGetError()}');
//         return Result.error(
//           Exception("Não foi possível fazer upload do documento."),
//         );
//       }

//       return result;
//     } catch (e, s) {
//       _logger.severe('Exception uploading document:', e, s);
//       return Result.error(
//         Exception("Ocorreu um erro desconhecido ao fazer upload do documento."),
//       );
//     }
//   }

//   void goToForm() {
//     currentStep.value = UploadStep.form;
//   }

//   void goBackToPreview() {
//     currentStep.value = UploadStep.preview;
//   }

//   void handleFormSubmit(DocumentFormData formData) {
//     uploadDocument.execute(formData);
//   }

//   void dispose() {
//     currentStep.dispose();
//   }
// }

// enum DocumentUploadMethod { scan, upload }

// enum UploadStep { preview, form }
