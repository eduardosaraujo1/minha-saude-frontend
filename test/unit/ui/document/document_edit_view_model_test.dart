import 'package:minha_saude_frontend/app/data/repositories/document/document_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:minha_saude_frontend/app/ui/documents/view_models/metadata/document_edit_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../mocks/mock_document_repository.dart';

void main() {
  late DocumentRepository documentRepository;
  late DocumentEditViewModel viewModel;
  const String documentUuid = 'test-uuid';

  setUp(() {
    documentRepository = MockDocumentRepository();
    viewModel = DocumentEditViewModel(
      documentUuid: documentUuid,
      documentRepository: documentRepository,
    );
  });

  test(
    "when loadDocument.execute is called, then repository getDocument should be invoked and command should expose success",
    () async {
      Document mockDocument = Document(
        uuid: documentUuid,
        titulo: 'Test Title',
        dataDocumento: DateTime(2024, 1, 1),
        medico: 'Dr. Smith',
        paciente: 'John Doe',
        tipo: 'Tipo A',
        createdAt: DateTime(2024, 1, 1),
      );

      when(
        () => documentRepository.getDocumentMeta(documentUuid),
      ).thenAnswer((_) async => Success(mockDocument));

      // Execute the command (this triggers async execution)
      viewModel.loadDocument.execute();

      // Wait a short time for the async operation to complete
      // If the operation takes too long, consider using a more robust synchronization method
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the command's value was updated with success
      expect(viewModel.loadDocument.value, isNotNull);
      expect(viewModel.loadDocument.value!.isSuccess(), isTrue);
      expect(viewModel.loadDocument.value!.tryGetSuccess(), mockDocument);

      // Verify the repository method was called
      verify(() => documentRepository.getDocumentMeta(documentUuid)).called(1);
    },
  );

  test(
    "when updateCommand is run then document is updated with provided data",
    () {
      // To be implemented when update functionality is added
    },
  );
}
