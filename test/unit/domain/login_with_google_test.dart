import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/session/session_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/login_with_google.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late LoginWithGoogle loginWithGoogle;
  setUp(() {
    authRepository = MockAuthRepository();
    sessionRepository = MockSessionRepository();
    loginWithGoogle = LoginWithGoogle(
      authRepository: authRepository,
      sessionRepository: sessionRepository,
    );
  });
}
