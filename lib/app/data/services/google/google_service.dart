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
    if (Environment.googleClientId.isEmpty ||
        Environment.googleServerClientId.isEmpty) {
      throw Exception(
        'Google Client ID and Server Client ID must be set in environment variables.',
      );
    }
    _signIn.initialize(
      clientId: Environment.googleClientId,
      serverClientId: Environment.googleServerClientId,
    );
  }

  final GoogleSignIn _signIn;

  @override
  Future<Result<String?, Exception>> generateServerAuthCode() async {
    try {
      // Try lightweight (silent) authentication first
      var account = await _signIn.attemptLightweightAuthentication();

      // If silent auth fails, prompt user for interactive authentication
      account ??= await _signIn.authenticate();

      // Get authorization client and request server auth code
      final client = account.authorizationClient;
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
