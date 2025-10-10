import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:minha_saude_frontend/app/ui/documents/view_models/metadata/document_edit_view_model.dart';
import 'package:minha_saude_frontend/app/ui/documents/widgets/metadata/document_edit_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../mocks/mock_document_repository.dart';

void main() {
  late DocumentEditViewModel viewModel;
  const String documentUuid = 'test-uuid';
  setUp(() {
    viewModel = DocumentEditViewModel(
      documentUuid: documentUuid,
      documentRepository: MockDocumentRepository(),
    );
  });
  testWidgets(
    "when all fields are filled and save button is pressed then repository is invoked",
    (tester) async {
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
        () => viewModel.documentRepository.updateDocument(
          documentUuid,
          titulo: any(named: 'titulo'),
          dataDocumento: any(named: 'dataDocumento'),
          medico: any(named: 'medico'),
          paciente: any(named: 'paciente'),
          tipo: any(named: 'tipo'),
        ),
      ).thenAnswer((_) async => Success(mockDocument));

      await tester.pumpWidget(DocumentEditScreen(viewModel));

      // Find TextFields and save button by key, asserting they exist
      expect(find.byKey(const ValueKey('tituloField')), findsOneWidget);
      expect(find.byKey(const ValueKey('dataDocumentoField')), findsOneWidget);
      expect(find.byKey(const ValueKey('medicoField')), findsOneWidget);
      expect(find.byKey(const ValueKey('pacienteField')), findsOneWidget);
      expect(find.byKey(const ValueKey('tipoField')), findsOneWidget);
      expect(find.byKey(const ValueKey('saveButton')), findsOneWidget);

      // Fill all fields with valid data
      tester.enterText(
        find.byKey(const ValueKey('tituloField')),
        mockDocument.titulo!,
      );
      tester.enterText(
        find.byKey(const ValueKey('dataDocumentoField')),
        DateFormat('dd-MM-yyyy').format(mockDocument.dataDocumento!),
      );
      tester.enterText(
        find.byKey(const ValueKey('medicoField')),
        mockDocument.medico!,
      );
      tester.enterText(
        find.byKey(const ValueKey('pacienteField')),
        mockDocument.paciente!,
      );
      tester.enterText(
        find.byKey(const ValueKey('tipoField')),
        mockDocument.tipo!,
      );

      // Press save button
      await tester.tap(find.byKey(const ValueKey('saveButton')));
      await tester.pumpAndSettle();

      // Expect repository method was called once
      verify(
        () => viewModel.documentRepository.updateDocument(
          documentUuid,
          titulo: mockDocument.titulo!,
          dataDocumento: mockDocument.dataDocumento!,
          medico: mockDocument.medico!,
          paciente: mockDocument.paciente!,
          tipo: mockDocument.tipo!,
        ),
      ).called(1);
    },
  );

  testWidgets(
    "when button back is pressed then navigator pops",
    (tester) async {},
  );
}
