import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/config/google_auth_config.dart';
import 'package:minha_saude_frontend/utils/result.dart';

const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/userinfo.email',
  'openid',
];

class GoogleAuthService {
  final GoogleSignIn _signIn;
  final GoogleAuthConfig _config;

  GoogleAuthService(this._signIn, this._config);

  Future<void> init() async {
    await _signIn.initialize(
      clientId: _config.clientId,
      serverClientId: _config.serverClientId,
    );
  }

  Future<Result<String?>> generateServerAuthCode() async {
    try {
      // Try silent auth
      var account = await _signIn.attemptLightweightAuthentication();

      // Fallback to interactive auth
      account ??= await _signIn.authenticate();

      // Now account is guaranteed non-null
      final client = account.authorizationClient;

      final serverAuth = await client.authorizeServer(scopes);

      if (serverAuth == null) {
        return Result.error(Exception('Failed to retrieve server auth code'));
      }

      return Result.ok(serverAuth.serverAuthCode);
    } on GoogleSignInException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }
}
