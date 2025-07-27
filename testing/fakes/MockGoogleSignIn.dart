import 'package:mocktail/mocktail.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthorizationClient extends Mock
    implements GoogleSignInAuthorizationClient {}
