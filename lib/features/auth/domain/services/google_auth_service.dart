import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/features/auth/domain/services/google_auth_config.dart';
import 'package:multiple_result/multiple_result.dart';

class GoogleAuthService {
  static const List<String> scopes = <String>[
    'https://www.googleapis.com/auth/userinfo.email',
    'openid',
  ];

  final GoogleSignIn _signIn;

  const GoogleAuthService._(this._signIn);

  static Future<GoogleAuthService> create(
    GoogleSignIn signIn,
    GoogleAuthConfig config,
  ) async {
    await signIn.initialize(
      clientId: config.clientId,
      serverClientId: config.serverClientId,
    );

    return GoogleAuthService._(signIn);
  }

  Future<Result<String?, Exception>> generateServerAuthCode() async {
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

      return Result.success(serverAuth.serverAuthCode);
    } on GoogleSignInException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }
}
