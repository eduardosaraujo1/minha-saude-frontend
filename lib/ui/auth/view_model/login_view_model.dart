import 'package:minha_saude_frontend/data/services/google_auth_client.dart';
import 'package:minha_saude_frontend/utils/result.dart';

class LoginViewModel {
  LoginViewModel(GoogleAuthClient authClient) : _authClient = authClient;
  final GoogleAuthClient _authClient;

  Future<void> signInWithGoogle() async {
    if (!_authClient.isSignedIn) {
      await _authClient.signIn();
    }
  }

  Future<Result<String?>> getAuthCode() async {
    return _authClient.getServerAuthCode();
  }
}
