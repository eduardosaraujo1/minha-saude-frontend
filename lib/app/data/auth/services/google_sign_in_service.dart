import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/config/google_auth_config.dart';
import 'package:multiple_result/multiple_result.dart';

class GoogleSignInService {
  static const List<String> scopes = <String>[
    'https://www.googleapis.com/auth/userinfo.email',
    'openid',
  ];

  final GoogleSignIn _signIn;

  const GoogleSignInService._(this._signIn);

  static Future<GoogleSignInService> create(
    GoogleSignIn signIn,
    GoogleAuthConfig config,
  ) async {
    await signIn.initialize(
      clientId: config.clientId,
      serverClientId: config.serverClientId,
    );

    return GoogleSignInService._(signIn);
  }

  Future<Result<String?, Exception>> generateServerAuthCode() async {
    // temporary mock
    // return Future.delayed(
    //   Duration(seconds: 2),
    //   () => Result.success("mock_server_auth_code"),
    // );
    try {
      // Try silent auth
      var account = await _signIn.attemptLightweightAuthentication();

      // Fallback to interactive auth
      account ??= await _signIn.authenticate();

      // Now account is guaranteed non-null
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
