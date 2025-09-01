import 'package:minha_saude_frontend/features/auth/domain/services/google_auth_config.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {
  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {
    return;
  }
}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthorizationClient extends Mock
    implements GoogleSignInAuthorizationClient {}

@override
class MockGoogleAuthConfig implements GoogleAuthConfig {
  @override
  final String clientId = '';

  @override
  final String serverClientId = '';
}
