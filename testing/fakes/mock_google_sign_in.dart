import 'package:minha_saude_frontend/config/google_auth_config.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

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
