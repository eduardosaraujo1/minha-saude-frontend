import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/data/repositories/document/document_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:minha_saude_frontend/app/ui/documents/view_models/metadata/document_edit_view_model.dart';
import 'package:minha_saude_frontend/app/ui/documents/widgets/metadata/document_edit_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../testing/app.dart';
import '../../../../testing/mocks/repositories/mock_document_repository.dart';
import '../../../../testing/mocks/mock_go_router.dart';
import '../../../../testing/models/document.dart';
import '../../../../testing/utils/format.dart';

class MockRoute extends Mock implements Route<dynamic> {}

void main() {
  late DocumentEditViewModel viewModel;
  late MockGoRouter mockGoRouter;
  late DocumentRepository documentRepository;
  const String documentUuid = 'test-uuid';
  late Widget view;
  Document mockDocument = randomDocument().copyWith(
    uuid: documentUuid,
    tipo: null,
  );
  Document mockUpdatedDocument = mockDocument.copyWith(
    titulo: 'Updated Title',
    dataDocumento: DateTime(2024, 2, 2),
    medico: 'Dr. Who',
    paciente: 'Jane Doe',
    tipo: 'Tipo B',
  );

  setUpAll(() {
    registerFallbackValue(MockRoute() as Route<dynamic>);
  });

  setUp(() {
    mockGoRouter = MockGoRouter();
    when(() => mockGoRouter.pop()).thenReturn(null);
    when(() => mockGoRouter.canPop()).thenReturn(true);

    documentRepository = MockDocumentRepository();
    when(
      () => documentRepository.getDocumentMeta(
        documentUuid,
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Success(mockDocument));
    when(
      () => documentRepository.updateDocument(
        any(),
        titulo: any(named: 'titulo'),
        paciente: any(named: 'paciente'),
        medico: any(named: 'medico'),
        tipo: any(named: 'tipo'),
        dataDocumento: any(named: 'dataDocumento'),
      ),
    ).thenAnswer((_) async => Success(mockUpdatedDocument));

    viewModel = DocumentEditViewModel(
      documentUuid: documentUuid,
      documentRepository: documentRepository,
    );
    view = testApp(
      Scaffold(body: DocumentEditScreen(() => viewModel)),
      mockGoRouter: mockGoRouter,
    );
  });

  testWidgets("has form fields, cancel and submit button", (tester) async {
    await tester.pumpWidget(view);

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
  });

  testWidgets("shows correct form data", (tester) async {
    await tester.pumpWidget(view);

    // Wait for loadDocument to complete and UI to update
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Fields contain correct data
    final titulo = mockDocument.titulo ?? '';
    final medico = mockDocument.medico ?? '';
    final paciente = mockDocument.paciente ?? '';
    final tipo = mockDocument.tipo ?? '';
    final dataDocumento = mockDocument.dataDocumento == null
        ? ''
        : formatDate(mockDocument.dataDocumento!);

    void textFieldHasText(Key key, String text) {
      expect(
        find.descendant(of: find.byKey(key), matching: find.text(text)),
        findsOneWidget,
      );
    }

    textFieldHasText(const ValueKey('dataDocumentoField'), dataDocumento);
    textFieldHasText(const ValueKey('tituloField'), titulo);
    textFieldHasText(const ValueKey('medicoField'), medico);
    textFieldHasText(const ValueKey('pacienteField'), paciente);
    textFieldHasText(const ValueKey('tipoField'), tipo);
  });

  testWidgets("submits correct form data", (tester) async {
    await tester.pumpWidget(view);

    // Await for the document to load
    await tester.pump(const Duration(milliseconds: 500));

    // Fill all fields with valid data
    Future<bool> fillWithText(Key key, String? text) async {
      if (text == null) return false;

      final field = find.byKey(key);
      expect(field, findsOneWidget);
      await tester.enterText(field, text);
      return true;
    }

    Future<bool> setFieldText(Key key, String? text) async {
      if (text == null) return false;

      var documentTextField = tester.widget<TextFormField>(find.byKey(key));
      documentTextField.controller!.text = text;
      return true;
    }

    final hasTitle = await fillWithText(
      const ValueKey('tituloField'),
      mockUpdatedDocument.titulo!,
    );
    // ignore: unused_local_variable
    final hasMedico = await fillWithText(
      const ValueKey('medicoField'),
      mockUpdatedDocument.medico!,
    );
    // ignore: unused_local_variable
    final hasPaciente = await fillWithText(
      const ValueKey('pacienteField'),
      mockUpdatedDocument.paciente!,
    );
    // ignore: unused_local_variable
    final hasTipo = await fillWithText(
      const ValueKey('tipoField'),
      mockUpdatedDocument.tipo!,
    );
    // This field is read-only and uses a date picker
    // So value must be set manually
    // ignore: unused_local_variable
    final hasDate = await setFieldText(
      const ValueKey('dataDocumentoField'),
      mockUpdatedDocument.dataDocumento != null
          ? formatDate(mockUpdatedDocument.dataDocumento!)
          : null,
    );

    expect(hasTitle, true);

    // Press save button
    await tester.tap(find.byKey(const ValueKey('saveButton')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    verify(
      () => viewModel.documentRepository.updateDocument(
        documentUuid,
        titulo: mockUpdatedDocument.titulo,
        dataDocumento: mockUpdatedDocument.dataDocumento,
        medico: mockUpdatedDocument.medico,
        paciente: mockUpdatedDocument.paciente,
        tipo: mockUpdatedDocument.tipo,
      ),
    ).called(1);
    expect(viewModel.updateDocument.value?.isSuccess(), true);
  });

  testWidgets("when cancel is clicked then pop is invoked", (tester) async {
    await tester.pumpWidget(view);
    await tester.pump(Duration(milliseconds: 200));

    // Tap cancel button
    await tester.tap(find.byKey(const ValueKey('cancelButton')));

    // Expect navigation pop occurred
    verify(() => mockGoRouter.pop()).called(1);
  });
}
