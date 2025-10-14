import 'package:intl/intl.dart';
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
      Document mockUpdatedDocument = Document(
        uuid: documentUuid,
        titulo: 'Updated Title',
        dataDocumento: DateTime(2024, 2, 2),
        medico: 'Dr. Who',
        paciente: 'Jane Doe',
        tipo: 'Tipo B',
        createdAt: DateTime(2024, 1, 1),
      );

      when(
        () => documentRepository.updateDocument(
          documentUuid,
          titulo: mockUpdatedDocument.titulo!,
          dataDocumento: mockUpdatedDocument.dataDocumento!,
          medico: mockUpdatedDocument.medico!,
          paciente: mockUpdatedDocument.paciente!,
          tipo: mockUpdatedDocument.tipo!,
        ),
      ).thenAnswer((_) async => Success(mockUpdatedDocument));

      when(
        () => documentRepository.getDocumentMeta(documentUuid),
      ).thenAnswer((_) async => Success(mockDocument));

      viewModel.loadDocument.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // Populate form fields
      viewModel.form.titulo.text = mockUpdatedDocument.titulo!;
      viewModel.form.dataDocumento.text = DateFormat(
        'dd/MM/yyyy',
      ).format(mockUpdatedDocument.dataDocumento!);
      viewModel.form.medico.text = mockUpdatedDocument.medico!;
      viewModel.form.paciente.text = mockUpdatedDocument.paciente!;
      viewModel.form.tipo.text = mockUpdatedDocument.tipo!;

      // Execute the update command
      viewModel.updateDocument.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the command's value was updated with success
      expect(viewModel.updateDocument.value?.isSuccess(), true);
      verify(
        () => documentRepository.updateDocument(
          documentUuid,
          titulo: mockUpdatedDocument.titulo!,
          dataDocumento: mockUpdatedDocument.dataDocumento!,
          medico: mockUpdatedDocument.medico!,
          paciente: mockUpdatedDocument.paciente!,
          tipo: mockUpdatedDocument.tipo!,
        ),
      ).called(1);
    },
  );
}
