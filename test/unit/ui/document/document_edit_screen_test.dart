import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:minha_saude_frontend/app/data/repositories/document/document_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:minha_saude_frontend/app/ui/documents/view_models/metadata/document_edit_view_model.dart';
import 'package:minha_saude_frontend/app/ui/documents/widgets/metadata/document_edit_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../mocks/mock_document_repository.dart';

void main() {
  late DocumentEditViewModel viewModel;
  late DocumentRepository documentRepository;
  const String documentUuid = 'test-uuid';
  setUp(() {
    documentRepository = MockDocumentRepository();
    viewModel = DocumentEditViewModel(
      documentUuid: documentUuid,
      documentRepository: documentRepository,
    );
  });

  testWidgets(
    "when widget is created and load is completed then text fields should contain the data",
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
        () => documentRepository.getDocumentMeta(documentUuid),
      ).thenAnswer((_) async => Success(mockDocument));

      await tester.pumpWidget(MaterialApp(home: DocumentEditScreen(viewModel)));

      // Wait for loadDocument to complete and UI to update
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Fields are present
      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.byKey(const ValueKey('tituloField')), findsOneWidget);
      expect(find.byKey(const ValueKey('dataDocumentoField')), findsOneWidget);
      expect(find.byKey(const ValueKey('medicoField')), findsOneWidget);
      expect(find.byKey(const ValueKey('pacienteField')), findsOneWidget);
      expect(find.byKey(const ValueKey('tipoField')), findsOneWidget);

      // Fields contain correct data
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('tituloField')),
          matching: find.text(mockDocument.titulo!),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dataDocumentoField')),
          matching: find.text(
            DateFormat('dd/MM/yyyy').format(mockDocument.dataDocumento!),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('medicoField')),
          matching: find.text(mockDocument.medico!),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('pacienteField')),
          matching: find.text(mockDocument.paciente!),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('tipoField')),
          matching: find.text(mockDocument.tipo!),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    "when all fields are updated and save button is pressed then document is updated",
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
        () => documentRepository.getDocumentMeta(documentUuid),
      ).thenAnswer((_) async => Success(mockDocument));
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

      await tester.pumpWidget(MaterialApp(home: DocumentEditScreen(viewModel)));

      // Await for the document to load
      await tester.pump(const Duration(milliseconds: 500));

      // Fill all fields with valid data
      await tester.enterText(
        find.byKey(const ValueKey('tituloField')),
        mockDocument.titulo!,
      );
      await tester.enterText(
        find.byKey(const ValueKey('dataDocumentoField')),
        DateFormat('dd-MM-yyyy').format(mockDocument.dataDocumento!),
      ); // This field is read-only and uses a date picker, not sure if the test can bypass that
      await tester.enterText(
        find.byKey(const ValueKey('medicoField')),
        mockDocument.medico!,
      );
      await tester.enterText(
        find.byKey(const ValueKey('pacienteField')),
        mockDocument.paciente!,
      );
      await tester.enterText(
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
          titulo: mockUpdatedDocument.titulo!,
          dataDocumento: mockUpdatedDocument.dataDocumento!,
          medico: mockUpdatedDocument.medico!,
          paciente: mockUpdatedDocument.paciente!,
          tipo: mockUpdatedDocument.tipo!,
        ),
      ).called(1);
    },
  );

  testWidgets("when cancel is clicked then pop is invoked", (tester) async {
    //
  });
}
