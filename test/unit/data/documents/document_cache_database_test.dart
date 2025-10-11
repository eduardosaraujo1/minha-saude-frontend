import 'package:minha_saude_frontend/app/data/services/cache_database/cache_database.dart';
import 'package:minha_saude_frontend/app/data/services/cache_database/cache_database_impl.dart';
import 'package:minha_saude_frontend/app/data/services/cache_database/models/document_db_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

void main() {
  late CacheDatabase db;

  setUpAll(() async {
    // Initialize FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = CacheDatabaseImpl();
    await db.init();
  });

  tearDown(() async {
    // Clean up the database after each test
    // await db.clear();
  });

  test("Data is available after insertion", () async {
    final Map<String, dynamic> documentData = {
      'uuid': 'test-doc-uuid',
      'titulo': 'titulo',
      'paciente': 'paciente',
      'medico': 'medico',
      'tipo': 'tipo',
      'data_documento': DateTime(2012, 2, 2).toIso8601String(),
      'deleted_at': null,
      'created_at': DateTime(2022, 2, 2).toIso8601String(),
      'cached_at': DateTime(2023, 1, 1).toIso8601String(),
    };

    final expectedModel = DocumentDbModel.fromJson(documentData);

    await db.upsertDocument(
      documentData['uuid'],
      titulo: documentData['titulo'],
      paciente: documentData['paciente'],
      medico: documentData['medico'],
      tipo: documentData['tipo'],
      dataDocumento: DateTime.parse(documentData['data_documento']),
      createdAt: DateTime.parse(documentData['created_at']),
      deletedAt: documentData['deleted_at'] != null
          ? DateTime.parse(documentData['deleted_at'])
          : null,
      cachedAt: DateTime.parse(documentData['cached_at']),
    );
    final retrievedData = await db.getDocument(documentData['uuid']);
    final retrievedDataValue = retrievedData.tryGetSuccess();

    expect(retrievedDataValue, isNotNull);
    expect(retrievedDataValue, equals(expectedModel));
  });

  test("List all database entries", () async {
    final allDocuments = await db.listDocuments();
    final list = allDocuments.tryGetSuccess();

    expect(list, isNotNull);
    expect(list, isA<List<DocumentDbModel>>());
    expect(list, hasLength(greaterThan(0)));
  });
}
