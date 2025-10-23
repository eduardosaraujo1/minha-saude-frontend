/// Integration tests for FakeApiGateway
///
/// Test cases:
/// - Authentication: login with Google/email, registration, logout, send email
/// - Profile: get profile, edit name/birthdate/phone, link Google, delete account
/// - Documents: upload, list, get, edit metadata, delete, download
/// - Trash: list, view, restore, destroy
/// - Shares: create, list, get details, delete
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/data/services/api/fakes/fake_api_gateway/fake_api_gateway.dart';
import 'package:minha_saude_frontend/app/data/services/api/fakes/fake_server_cache_engine.dart';
import 'package:minha_saude_frontend/app/data/services/api/fakes/fake_server_database.dart';
import 'package:minha_saude_frontend/app/data/services/api/fakes/fake_server_file_storage.dart';
import 'package:minha_saude_frontend/app/data/services/api/gateway/routes.dart';
import 'package:minha_saude_frontend/app/data/services/sqlite/sqlite_database.dart';

void main() {
  late FakeApiGateway fakeApiGateway;
  late FakeServerCacheEngine fakeServerCacheEngine;
  late FakeServerDatabase fakeServerDatabase;
  late FakeServerFileStorage fakeServerFileStorage;

  setUp(() async {
    fakeServerCacheEngine = FakeServerCacheEngine();
    fakeServerDatabase = FakeServerDatabase(
      sqliteDatabase: SqliteDatabase.forFakeServerDatabase(inMemory: true),
    );
    fakeServerFileStorage = FakeServerFileStorage();
    fakeApiGateway = FakeApiGateway(
      fakeServerCacheEngine: fakeServerCacheEngine,
      fakeServerDatabase: fakeServerDatabase,
      fakeServerFileStorage: fakeServerFileStorage,
    );

    // Initialize database
    await fakeServerDatabase.init();
  });

  tearDown(() async {
    await fakeServerDatabase.clearAll();
  });

  group("Authentication", () {
    test("Login with Google - New User", () async {
      final result = await fakeApiGateway.post(
        GatewayRoutes.loginGoogle,
        data: {'tokenOauth': 'fake_oauth_token'},
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['isRegistered'], false);
      expect(response['sessionToken'], null);
      expect(response['registerToken'], isNotNull);

      // Verify register token is cached
      final registerToken = response['registerToken'] as String;
      final cachedData = fakeServerCacheEngine.get(registerToken);
      expect(cachedData, isNotNull);
      expect(cachedData['email'], 'eduardosaraujo100@gmail.com');
      expect(cachedData['metodoAutenticacao'], 'google');
    });

    test("Send Email Verification Code", () async {
      const email = 'test@example.com';
      final result = await fakeApiGateway.post(
        GatewayRoutes.sendEmail,
        data: {'email': email},
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['status'], 'success');

      // Verify code is stored in cache
      final code = fakeServerCacheEngine.get('email_code_$email');
      expect(code, '100000');
    });

    test("Login with Email - New User", () async {
      const email = 'test@example.com';

      // First send email verification code
      await fakeApiGateway.post(
        GatewayRoutes.sendEmail,
        data: {'email': email},
      );

      // Then login with the code
      final result = await fakeApiGateway.post(
        GatewayRoutes.loginEmail,
        data: {'email': email, 'codigoEmail': '100000'},
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['isRegistered'], false);
      expect(response['sessionToken'], null);
      expect(response['registerToken'], isNotNull);

      // Verify register token is cached
      final registerToken = response['registerToken'] as String;
      final cachedData = fakeServerCacheEngine.get(registerToken);
      expect(cachedData, isNotNull);
      expect(cachedData['email'], email);
      expect(cachedData['metodoAutenticacao'], 'email');
    });

    test("Register User with Google", () async {
      // First login to get register token
      final loginResult = await fakeApiGateway.post(
        GatewayRoutes.loginGoogle,
        data: {'tokenOauth': 'fake_oauth_token'},
      );
      final registerToken =
          loginResult.tryGetSuccess()!['registerToken'] as String;

      // Now register
      final registerResult = await fakeApiGateway.post(
        GatewayRoutes.registerUser,
        data: {
          'user': {
            'nome': 'Test User',
            'cpf': '12345678901',
            'dataNascimento': '1990-01-01',
            'telefone': '11999999999',
          },
          'registerToken': registerToken,
        },
      );

      expect(registerResult.isSuccess(), true);
      final response = registerResult.tryGetSuccess()!;
      expect(response['sessionToken'], isNotNull);

      // Verify user is in database
      final users = await fakeServerDatabase.users.readAll();
      expect(users.length, 1);
      expect(users.first['nome'], 'Test User');
      expect(users.first['cpf'], '12345678901');
      expect(users.first['email'], 'eduardosaraujo100@gmail.com');
      expect(users.first['metodo_autenticacao'], 'google');

      // Verify register token is cleared
      final cachedData = fakeServerCacheEngine.get(registerToken);
      expect(cachedData, null);
    });

    test("Login with Google - Existing User", () async {
      // First register a user
      final loginResult1 = await fakeApiGateway.post(
        GatewayRoutes.loginGoogle,
        data: {'tokenOauth': 'fake_oauth_token'},
      );
      final registerToken =
          loginResult1.tryGetSuccess()!['registerToken'] as String;

      await fakeApiGateway.post(
        GatewayRoutes.registerUser,
        data: {
          'user': {
            'nome': 'Test User',
            'cpf': '12345678901',
            'dataNascimento': '1990-01-01',
          },
          'registerToken': registerToken,
        },
      );

      // Now login again with same email
      final loginResult2 = await fakeApiGateway.post(
        GatewayRoutes.loginGoogle,
        data: {'tokenOauth': 'another_fake_token'},
      );

      expect(loginResult2.isSuccess(), true);
      final response = loginResult2.tryGetSuccess()!;
      expect(response['isRegistered'], true);
      expect(response['sessionToken'], isNotNull);
      expect(response['registerToken'], null);
    });

    test("Logout", () async {
      final result = await fakeApiGateway.post(GatewayRoutes.logout);

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['status'], 'success');
    });
  });

  group("Profile", () {
    setUp(() async {
      // Create a test user for profile tests
      await fakeServerDatabase.users.create({
        'cpf': '12345678901',
        'nome': 'Test User',
        'data_nascimento': '1990-01-01',
        'telefone': '11999999999',
        'email': 'test@example.com',
        'metodo_autenticacao': 'email',
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    test("Get User Profile", () async {
      final result = await fakeApiGateway.get(GatewayRoutes.getUserProfile);

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['nome'], 'Test User');
      expect(response['cpf'], '12345678901');
      expect(response['email'], 'test@example.com');
      expect(response['telefone'], '11999999999');
      expect(response['dataNascimento'], '1990-01-01');
      expect(response['metodoAutenticacao'], 'email');
    });

    test("Edit Name", () async {
      final result = await fakeApiGateway.put(
        GatewayRoutes.editName,
        data: {'nome': 'Updated Name'},
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['nome'], 'Updated Name');

      // Verify in database
      final users = await fakeServerDatabase.users.readAll();
      expect(users.first['nome'], 'Updated Name');
    });

    test("Edit Birthdate", () async {
      final result = await fakeApiGateway.put(
        GatewayRoutes.editBirthdate,
        data: {'dataNascimento': '1995-05-15'},
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['dataNascimento'], '1995-05-15');

      // Verify in database
      final users = await fakeServerDatabase.users.readAll();
      expect(users.first['data_nascimento'], '1995-05-15');
    });

    test("Send Phone SMS", () async {
      const telefone = '11988888888';
      final result = await fakeApiGateway.post(
        GatewayRoutes.sendPhoneSms,
        data: {'telefone': telefone},
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['status'], 'success');

      // Verify code is stored
      final code = fakeServerCacheEngine.get('sms_code_$telefone');
      expect(code, '100000');
    });

    test("Edit Phone", () async {
      const telefone = '11988888888';

      // First send SMS
      await fakeApiGateway.post(
        GatewayRoutes.sendPhoneSms,
        data: {'telefone': telefone},
      );

      // Then update phone
      final result = await fakeApiGateway.put(
        GatewayRoutes.editPhone,
        data: {'telefone': telefone, 'codigoSms': '100000'},
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['telefone'], telefone);

      // Verify in database
      final users = await fakeServerDatabase.users.readAll();
      expect(users.first['telefone'], telefone);

      // Verify SMS code is cleared
      final code = fakeServerCacheEngine.get('sms_code_$telefone');
      expect(code, null);
    });

    test("Link Google Account", () async {
      final result = await fakeApiGateway.post(
        GatewayRoutes.linkGoogleAccount,
        data: {'tokenOauth': 'fake_google_token'},
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['status'], 'success');

      // Verify in database
      final users = await fakeServerDatabase.users.readAll();
      expect(users.first['google_id'], isNotNull);
      expect(users.first['metodo_autenticacao'], 'google');
    });

    test("Delete Account", () async {
      final result = await fakeApiGateway.delete(
        GatewayRoutes.deleteAccount,
        data: {
          'authType': 'email',
          'auth': {'email': 'test@example.com', 'codigoEmail': '100000'},
        },
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['status'], 'success');

      // Verify user is soft-deleted (deleted_at is set)
      final user = await fakeServerDatabase.users.findByEmail(
        'test@example.com',
      );
      expect(user!['deleted_at'], isNotNull);
    });
  });

  group("Documents", () {
    setUp(() async {
      // Create a test user
      await fakeServerDatabase.users.create({
        'cpf': '12345678901',
        'nome': 'Test User',
        'data_nascimento': '1990-01-01',
        'email': 'test@example.com',
        'metodo_autenticacao': 'email',
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    test("Upload Document", () async {
      final result = await fakeApiGateway.post(
        GatewayRoutes.uploadDocument,
        data: {
          'titulo': 'Test Document',
          'nomePaciente': 'John Doe',
          'nomeMedico': 'Dr. Smith',
          'tipoDocumento': 'Exame',
          'dataDocumento': '2024-01-15',
        },
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['status'], 'success');

      // Verify document is in database
      final users = await fakeServerDatabase.users.readAll();
      final docs = await fakeServerDatabase.documents.findByUser(
        users.first['id'] as int,
      );
      expect(docs.length, 1);
      expect(docs.first['titulo'], 'Test Document');
      expect(docs.first['nome_paciente'], 'John Doe');
      expect(docs.first['nome_medico'], 'Dr. Smith');
      expect(docs.first['tipo_documento'], 'Exame');
      expect(docs.first['data_documento'], '2024-01-15');
    });

    test("List Documents", () async {
      // Create multiple documents
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      await fakeServerDatabase.documents.create({
        'uuid': 'doc1',
        'titulo': 'Document 1',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      await fakeServerDatabase.documents.create({
        'uuid': 'doc2',
        'titulo': 'Document 2',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.get(GatewayRoutes.listDocuments);

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['data'].length, 2);
      expect(response['pagination']['total'], 2);
    });

    test("Get Document", () async {
      // Create a document
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      await fakeServerDatabase.documents.create({
        'uuid': 'test-doc-uuid',
        'titulo': 'Test Document',
        'nome_paciente': 'John Doe',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.get('/documents/test-doc-uuid');

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['titulo'], 'Test Document');
      expect(response['nomePaciente'], 'John Doe');
    });

    test("Edit Document Metadata", () async {
      // Create a document
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      await fakeServerDatabase.documents.create({
        'uuid': 'test-doc-uuid',
        'titulo': 'Original Title',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.put(
        '/documents/test-doc-uuid',
        data: {'titulo': 'Updated Title', 'nomePaciente': 'Jane Doe'},
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['titulo'], 'Updated Title');
      expect(response['nomePaciente'], 'Jane Doe');

      // Verify in database
      final doc = await fakeServerDatabase.documents.findByUuid(
        'test-doc-uuid',
      );
      expect(doc!['titulo'], 'Updated Title');
      expect(doc['nome_paciente'], 'Jane Doe');
    });

    test("Delete Document", () async {
      // Create a document
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      await fakeServerDatabase.documents.create({
        'uuid': 'test-doc-uuid',
        'titulo': 'Test Document',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.delete('/documents/test-doc-uuid');

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['message'], 'Document moved to trash');
      expect(response['dataExclusao'], isNotNull);

      // Verify document is soft-deleted
      final doc = await fakeServerDatabase.documents.findByUuid(
        'test-doc-uuid',
      );
      expect(doc!['deleted_at'], isNotNull);
    });

    test("Download Document", () async {
      // Create a document
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      await fakeServerDatabase.documents.create({
        'uuid': 'test-doc-uuid',
        'titulo': 'Test Document',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.get(
        '/documents/test-doc-uuid/download',
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['arquivoBase64'], isNotNull);
    });

    test("List Categories", () async {
      // Create documents with different categories
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      await fakeServerDatabase.documents.create({
        'uuid': 'doc1',
        'titulo': 'Doc 1',
        'nome_paciente': 'Patient A',
        'nome_medico': 'Dr. X',
        'tipo_documento': 'Exame',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      await fakeServerDatabase.documents.create({
        'uuid': 'doc2',
        'titulo': 'Doc 2',
        'nome_paciente': 'Patient B',
        'nome_medico': 'Dr. Y',
        'tipo_documento': 'Receita',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.get(GatewayRoutes.listCategories);

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      final data = response['data'] as Map<String, dynamic>;
      expect(data['pacientes'].contains('Patient A'), true);
      expect(data['pacientes'].contains('Patient B'), true);
      expect(data['medicos'].contains('Dr. X'), true);
      expect(data['medicos'].contains('Dr. Y'), true);
      expect(data['tipos'].contains('Exame'), true);
      expect(data['tipos'].contains('Receita'), true);
    });
  });

  group("Trash", () {
    setUp(() async {
      // Create a test user
      await fakeServerDatabase.users.create({
        'cpf': '12345678901',
        'nome': 'Test User',
        'data_nascimento': '1990-01-01',
        'email': 'test@example.com',
        'metodo_autenticacao': 'email',
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    test("List Trash", () async {
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      // Create a deleted document
      await fakeServerDatabase.documents.create({
        'uuid': 'deleted-doc',
        'titulo': 'Deleted Document',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
        'deleted_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.get(GatewayRoutes.listTrash);

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['data'].length, 1);
      expect(response['data'][0]['titulo'], 'Deleted Document');
    });

    test("View Trash Document", () async {
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      await fakeServerDatabase.documents.create({
        'uuid': 'deleted-doc',
        'titulo': 'Deleted Document',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
        'deleted_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.get('/trash/deleted-doc');

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['titulo'], 'Deleted Document');
      expect(response['deletedAt'], isNotNull);
    });

    test("Restore Document from Trash", () async {
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      await fakeServerDatabase.documents.create({
        'uuid': 'deleted-doc',
        'titulo': 'Deleted Document',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
        'deleted_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.post('/trash/deleted-doc/restore');

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['status'], 'success');

      // Verify document is restored
      final doc = await fakeServerDatabase.documents.findByUuid('deleted-doc');
      expect(doc!['deleted_at'], null);
    });

    test("Permanently Destroy Document", () async {
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      await fakeServerDatabase.documents.create({
        'uuid': 'deleted-doc',
        'titulo': 'Deleted Document',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
        'deleted_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.post('/trash/deleted-doc/destroy');

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['status'], 'success');

      // Verify document is permanently deleted
      final doc = await fakeServerDatabase.documents.findByUuid('deleted-doc');
      expect(doc, null);
    });
  });

  group("Shares", () {
    setUp(() async {
      // Create a test user
      await fakeServerDatabase.users.create({
        'cpf': '12345678901',
        'nome': 'Test User',
        'data_nascimento': '1990-01-01',
        'email': 'test@example.com',
        'metodo_autenticacao': 'email',
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    test("Create Share", () async {
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      // Create documents
      final doc1Id = await fakeServerDatabase.documents.create({
        'uuid': 'doc1',
        'titulo': 'Document 1',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      final doc2Id = await fakeServerDatabase.documents.create({
        'uuid': 'doc2',
        'titulo': 'Document 2',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.post(
        GatewayRoutes.createShare,
        data: {
          'idsDocumentos': [doc1Id, doc2Id],
        },
      );

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['codigo'], isNotNull);

      // Verify share is in database
      final shareCode = response['codigo'] as String;
      final share = await fakeServerDatabase.shares.findByCode(shareCode);
      expect(share, isNotNull);

      // Verify documents are linked
      final docs = await fakeServerDatabase.shares.getDocuments(
        share!['id'] as int,
      );
      expect(docs.length, 2);
    });

    test("List Shares", () async {
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      // Create a share
      await fakeServerDatabase.shares.create({
        'codigo': 'SHARE123',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.get(GatewayRoutes.listShares);

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['data'].length, 1);
      expect(response['data'][0]['codigo'], 'SHARE123');
    });

    test("Get Share Details", () async {
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      // Create document
      final docId = await fakeServerDatabase.documents.create({
        'uuid': 'doc1',
        'titulo': 'Shared Document',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Create share
      final shareId = await fakeServerDatabase.shares.create({
        'codigo': 'SHARE123',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Link document
      await fakeServerDatabase.shares.addDocument(shareId, docId);

      final result = await fakeApiGateway.get('/shares/SHARE123');

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['codigo'], 'SHARE123');
      expect(response['documentos'].length, 1);
      expect(response['documentos'][0]['titulo'], 'Shared Document');
    });

    test("Delete Share", () async {
      final users = await fakeServerDatabase.users.readAll();
      final userId = users.first['id'] as int;

      // Create share
      await fakeServerDatabase.shares.create({
        'codigo': 'SHARE123',
        'fk_id_usuario': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      final result = await fakeApiGateway.delete('/shares/SHARE123');

      expect(result.isSuccess(), true);
      final response = result.tryGetSuccess()!;
      expect(response['status'], 'success');

      // Verify share is soft-deleted
      final share = await fakeServerDatabase.shares.findByCode('SHARE123');
      expect(share, null); // findByCode filters out deleted shares
    });
  });
}
