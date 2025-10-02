import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/config/environment.dart';
import 'package:multiple_result/multiple_result.dart';

export 'google_service_fake.dart';

abstract class GoogleService {
  /// Generates a server authentication code for the currently signed-in user.
  /// Calls Google Sign-In SDK to perform authentication.
  /// Returns a [Result] containing the server auth code on success,
  Future<Result<String?, Exception>> generateServerAuthCode();
}

class GoogleServiceImpl implements GoogleService {
  static const List<String> scopes = [
    'https://www.googleapis.com/auth/userinfo.email',
    'openid',
  ];

  GoogleServiceImpl(this._signIn) {
    _signIn.initialize(
      clientId: Environment.googleClientId,
      serverClientId: Environment.googleServerClientId,
    );
  }

  final GoogleSignIn _signIn;

  @override
  Future<Result<String?, Exception>> generateServerAuthCode() async {
    try {
      // Try silent auth
      var account = await _signIn.attemptLightweightAuthentication();

      // Fallback to interactive auth
      account ??= await _signIn.authenticate();

      // Now account is guaranteed non-null
      final client = account.authorizationClient;
      // TODO: "some platforms only provide a valid server auth token on initial login. Clients requiring a server auth token should not rely on being able to re-request server auth tokens at arbitrary times, and should instead store the token when it is first available, and manage refreshes on the server side using that token.  "
      final serverAuth = await client.authorizeServer(scopes);

      if (serverAuth == null || serverAuth.serverAuthCode.isEmpty) {
        return Result.error(Exception('Failed to retrieve server auth code'));
      }

      return Result.success(serverAuth.serverAuthCode);
    } on GoogleSignInException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }
}
