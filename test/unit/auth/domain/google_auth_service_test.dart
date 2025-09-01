import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:minha_saude_frontend/features/auth/domain/services/google_auth_service.dart';
import 'package:multiple_result/multiple_result.dart';

import '../mocks/mock_google_sign_in.dart';

void main() {
  const serverAuthTemplate =
      "4/AdlKS89Hs9sjaD2398EBhsjai0_SJAHDJHLSAJDN021nlkkSKmsk98dK";
  const scopes = ['https://www.googleapis.com/auth/userinfo.email', 'openid'];

  late GoogleAuthService googleAuthService;
  late GoogleSignIn mockGoogleSignIn;
  late GoogleSignInAccount mockGoogleSignInAccount;
  late GoogleSignInAuthorizationClient mockGoogleSignInAuthorizationClient;
  late GoogleSignInServerAuthorization googleSignInServerAuthorization;

  setUpAll(() {
    // Needed for mocktail when matching List<String>
    registerFallbackValue(<String>[]);
  });

  setUp(() async {
    mockGoogleSignIn = MockGoogleSignIn();
    googleAuthService = await GoogleAuthService.create(
      mockGoogleSignIn,
      MockGoogleAuthConfig(),
    );

    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthorizationClient = MockGoogleSignInAuthorizationClient();

    googleSignInServerAuthorization = GoogleSignInServerAuthorization(
      serverAuthCode: serverAuthTemplate,
    );
  });

  group('generateServerAuthCode', () {
    test('returns server auth code when authenticated', () async {
      // Arrange
      when(
        () => mockGoogleSignIn.attemptLightweightAuthentication(),
      ).thenAnswer((_) async => mockGoogleSignInAccount);

      when(
        () => mockGoogleSignIn.authenticate(),
      ).thenAnswer((_) async => mockGoogleSignInAccount);

      when(
        () => mockGoogleSignInAccount.authorizationClient,
      ).thenReturn(mockGoogleSignInAuthorizationClient);

      when(
        () => mockGoogleSignInAuthorizationClient.authorizeServer(scopes),
      ).thenAnswer((_) async => googleSignInServerAuthorization);

      // Act
      final result = await googleAuthService.generateServerAuthCode();

      // Assert
      final value = result.getOrThrow();
      expect(value, equals(serverAuthTemplate));
    });

    test('returns Error when login fails', () async {
      // Arrange
      when(
        () => mockGoogleSignIn.attemptLightweightAuthentication(),
      ).thenAnswer((_) async => null);

      when(() => mockGoogleSignIn.authenticate()).thenThrow(
        GoogleSignInException(code: GoogleSignInExceptionCode.unknownError),
      );

      // Act
      final result = await googleAuthService.generateServerAuthCode();

      // Assert
      expect(result, isA<Error>());
    });
  });
}
