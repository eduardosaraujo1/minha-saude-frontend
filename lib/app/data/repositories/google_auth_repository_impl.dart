import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/app/domain/repositories/google_auth_repository.dart';
import 'package:minha_saude_frontend/core/config/google_auth_config.dart';
import 'package:minha_saude_frontend/core/config/mock_endpoint_config.dart';
import 'package:minha_saude_frontend/di/container.dart';
import 'package:multiple_result/multiple_result.dart';

class GoogleAuthRepositoryImpl implements GoogleAuthRepository {
  final GoogleAuthConfig googleAuthConfig;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  final List<String> _scopes;

  GoogleAuthRepositoryImpl(this.googleAuthConfig)
    : _scopes = googleAuthConfig.scopes;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await googleSignIn.initialize(
      clientId: googleAuthConfig.clientId,
      serverClientId: googleAuthConfig.serverClientId,
    );

    _isInitialized = true;
  }

  @override
  Future<Result<String, Exception>> getServerAuthCode() async {
    final mock = ServiceLocator.I<MockEndpointConfig>();

    // Mock response based on configuration
    if (mock.googleSignInMode == GoogleSignInMode.mockSuccess) {
      return Future.delayed(
        Duration(seconds: 2),
        () => Result.success("mock_server_auth_code"),
      );
    }

    if (mock.googleSignInMode == GoogleSignInMode.mockError) {
      return Future.delayed(
        Duration(seconds: 2),
        () => Result.error(Exception('Failed to retrieve server auth code')),
      );
    }

    // Real implementation
    try {
      // Try silent auth
      var account = await googleSignIn.attemptLightweightAuthentication();

      // Fallback to interactive auth
      account ??= await googleSignIn.authenticate();

      // Now account is guaranteed non-null
      final client = account.authorizationClient;

      final serverAuth = await client.authorizeServer(_scopes);

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
