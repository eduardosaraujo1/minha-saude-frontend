import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/app/data/services/google/google_auth_config.dart';
import 'package:multiple_result/multiple_result.dart';

export 'google_auth_config.dart';
export 'google_service_fake.dart';

abstract class GoogleService {
  /// Generates a server authentication code for the currently signed-in user.
  /// Calls Google Sign-In SDK to perform authentication.
  /// Returns a [Result] containing the server auth code on success,
  Future<Result<String?, Exception>> generateServerAuthCode();
}

class GoogleServiceImpl implements GoogleService {
  GoogleServiceImpl(GoogleAuthConfig config, GoogleSignIn signIn)
    : _config = config,
      _signIn = signIn;

  final GoogleAuthConfig _config;
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
      final serverAuth = await client.authorizeServer(_config.scopes);

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
