import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/document/document_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/session/session_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/logout.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

class MockDocumentRepository extends Mock implements DocumentRepository {}

void main() {
  late AuthRepository authRepository;
  late DocumentRepository documentRepository;
  late SessionRepository sessionRepository;
  late Logout logout;

  setUp(() {
    authRepository = MockAuthRepository();
    documentRepository = MockDocumentRepository();
    sessionRepository = MockSessionRepository();
    logout = Logout(
      documentRepository: documentRepository,
      authRepository: authRepository,
      sessionRepository: sessionRepository,
    );
  });
}
