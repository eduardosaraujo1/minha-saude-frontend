import 'dart:io';

import 'package:minha_saude_frontend/app/data/repositories/document/document_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';
import 'package:minha_saude_frontend/app/ui/documents/view_models/upload/document_upload_view_model.dart';

class MockDocumentRepository extends Mock implements DocumentRepository {}

void main() {
  late DocumentRepository mockDocumentRepository;
  setUp(() {
    mockDocumentRepository = MockDocumentRepository();
  });

  group("Document Load", () {
    test(
      "given a null file when loadDocument is called then it should store an error",
      () async {
        // Arrange
        final viewModel = DocumentUploadViewModel(
          DocumentUploadMethod.upload,
          mockDocumentRepository,
        );

        when(
          () => mockDocumentRepository.pickDocumentFile(),
        ).thenAnswer((_) async => Error(Exception("User cancelled")));

        // Act
        await viewModel.uploadDocument.execute();

        // Assert
        expect(viewModel.loadDocument.isError, true);
      },
    );
    test(
      "given a null file when loadDocument is called on scan then it should store an error",
      () async {
        // Arrange
        when(
          () => mockDocumentRepository.scanDocumentFile(),
        ).thenAnswer((_) async => Error(Exception("User cancelled")));

        // Act
        // load is run when instance is created
        final viewModel = DocumentUploadViewModel(
          DocumentUploadMethod.scan,
          mockDocumentRepository,
        );

        // Assert
        expect(viewModel.loadDocument.isError, true);
      },
    );
    test(
      "given a valid DocumentRepository when loadFile is called with a scan method then it should call scanDocumentFile on the repository and store the file",
      () async {
        // Arrange

        when(
          () => mockDocumentRepository.scanDocumentFile(),
        ).thenAnswer((_) async => Success(File("path/to/document.pdf")));

        // Act
        // load is run when instance is created
        final viewModel = DocumentUploadViewModel(
          DocumentUploadMethod.scan,
          mockDocumentRepository,
        );

        // Assert
        expect(viewModel.loadDocument.isSuccess, true);
        expect(viewModel.uploadedFile, isNotNull);
        verify(() => mockDocumentRepository.scanDocumentFile()).called(1);
      },
    );
    test(
      "given a valid DocumentRepository when loadFile is called with an upload method then it should call pickDocumentFile on the repository and store the file",
      () async {
        // Arrange
        when(
          () => mockDocumentRepository.pickDocumentFile(),
        ).thenAnswer((_) async => Success(File("path/to/document.pdf")));

        // Act
        // load is run when instance is created
        final viewModel = DocumentUploadViewModel(
          DocumentUploadMethod.upload,
          mockDocumentRepository,
        );

        // Assert
        expect(viewModel.loadDocument.isSuccess, true);
        expect(viewModel.uploadedFile, isNotNull);
        verify(() => mockDocumentRepository.pickDocumentFile()).called(1);
      },
    );
  });
}
