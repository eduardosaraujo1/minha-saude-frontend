import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:minha_saude_frontend/app/ui/documents/view_models/upload/document_upload_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../testing/mocks/mock_file.dart';
import '../../../../testing/mocks/repositories/mock_document_repository.dart';
import '../../../../testing/models/document.dart';

void main() {
  late DocumentUploadViewModel viewModel;
  late MockDocumentRepository mockDocumentRepository;

  late MockFile mockFile;
  final Document documentMeta = randomDocument();

  setUpAll(() {
    registerFallbackValue(MockFile() as File);
  });

  setUp(() {
    mockFile = MockFile();
    mockDocumentRepository = MockDocumentRepository();

    // Arrange: mock file properties
    when(() => mockFile.path).thenReturn('/path/to/mock/document.pdf');
    when(() => mockFile.length()).thenAnswer((_) async => 1024);
    when(
      () => mockFile.readAsBytes(),
    ).thenAnswer((_) async => Uint8List.fromList([0, 1, 2, 3, 4, 5]));

    // Arrange: successful document upload by default
    when(
      () => mockDocumentRepository.uploadDocument(
        mockFile,
        titulo: documentMeta.titulo,
        medico: documentMeta.medico,
        paciente: documentMeta.paciente,
        tipo: documentMeta.tipo,
        dataDocumento: documentMeta.dataDocumento,
      ),
    ).thenAnswer((_) async => Success(documentMeta));

    // Arrange: successful file picking by default
    when(
      () => mockDocumentRepository.pickDocumentFile(),
    ).thenAnswer((_) async => Success(mockFile));

    viewModel = DocumentUploadViewModel(
      type: DocumentUploadMethod.filePicker,
      documentRepository: mockDocumentRepository,
    );
  });

  /** Business Requirements
   * Group: File Picker
   * It gets a document file using the file picker
   * It handles errors when the the file picking fails
   * Group: Document Scanner
   * It gets a document file using the document scanner
   * It handles errors when the the document scanning fails
   * Group: Uploading Document
   * It uploads a document with the provided metadata and file to server
   * It does not upload if invalid metadata is provided
   */

  group("File Picker Model", () {
    test("it gets a document file using the file picker", () async {
      // Act
      viewModel.getDocumentCommand.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(viewModel.getDocumentCommand.value?.tryGetSuccess(), mockFile);
    });

    test("it handles errors when the file picking fails", () async {
      // Arrange
      final exception = Exception('File picker failed');
      when(
        () => mockDocumentRepository.pickDocumentFile(),
      ).thenAnswer((_) async => Error(exception));

      // Act
      viewModel.getDocumentCommand.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(viewModel.getDocumentCommand.value?.isError(), true);
    });
  });

  group("Document Scanner Model", () {
    late DocumentUploadViewModel scannerViewModel;

    setUp(() {
      scannerViewModel = DocumentUploadViewModel(
        type: DocumentUploadMethod.docScanner,
        documentRepository: mockDocumentRepository,
      );
    });

    test("it gets a document file using the document scanner", () async {
      // Arrange
      when(
        () => mockDocumentRepository.scanDocumentFile(),
      ).thenAnswer((_) async => Success(mockFile));

      // Act
      scannerViewModel.getDocumentCommand.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(
        scannerViewModel.getDocumentCommand.value?.tryGetSuccess(),
        mockFile,
      );
    });

    test("it handles errors when the document scanning fails", () async {
      // Arrange
      final exception = Exception('Document scanner failed');
      when(
        () => mockDocumentRepository.scanDocumentFile(),
      ).thenAnswer((_) async => Error(exception));

      // Act
      scannerViewModel.getDocumentCommand.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(scannerViewModel.getDocumentCommand.value?.isError(), true);
    });
  });

  group("Uploading Document", () {
    test(
      "it uploads a document with the provided metadata and file to server",
      () async {
        // Arrange
        viewModel.documentTitle.value = documentMeta.titulo;
        viewModel.getDocumentCommand.execute();
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        final result = viewModel.triggerUploadWithMetadata(
          nomePaciente: documentMeta.paciente,
          nomeMedico: documentMeta.medico,
          tipoDocumento: documentMeta.tipo,
          dataDocumento: documentMeta.dataDocumento,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(result, isA<Success>());
        verify(
          () => mockDocumentRepository.uploadDocument(
            mockFile,
            titulo: documentMeta.titulo,
            medico: documentMeta.medico,
            paciente: documentMeta.paciente,
            tipo: documentMeta.tipo,
            dataDocumento: documentMeta.dataDocumento,
          ),
        ).called(1);
      },
    );

    test("it does not upload if invalid metadata is provided", () async {
      // Arrange
      viewModel.getDocumentCommand.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act - empty title
      var result = viewModel.triggerUploadWithMetadata(
        nomePaciente: 'John Doe',
        nomeMedico: 'Dr. Smith',
      );

      // Assert
      expect(result.isError(), true);

      // Verify upload was never called
      verifyNever(
        () => mockDocumentRepository.uploadDocument(
          any(),
          titulo: any(named: 'titulo'),
          medico: any(named: 'medico'),
          paciente: any(named: 'paciente'),
          tipo: any(named: 'tipo'),
          dataDocumento: any(named: 'dataDocumento'),
        ),
      );
    });

    test("it does not upload if no document file is available", () async {
      // Arrange
      viewModel.documentTitle.value = 'Test Document';
      // Don't call getDocumentCommand, so file is not available

      // Act
      final result = viewModel.triggerUploadWithMetadata(
        nomePaciente: 'John Doe',
        nomeMedico: 'Dr. Smith',
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(result.isError(), true);

      // Verify upload was never called
      verifyNever(
        () => mockDocumentRepository.uploadDocument(
          any(),
          titulo: any(named: 'titulo'),
          medico: any(named: 'medico'),
          paciente: any(named: 'paciente'),
          tipo: any(named: 'tipo'),
          dataDocumento: any(named: 'dataDocumento'),
        ),
      );
    });
  });
}
