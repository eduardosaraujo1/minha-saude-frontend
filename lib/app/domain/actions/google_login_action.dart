import '../repositories/auth_repository.dart';
import '../repositories/google_auth_repository.dart';
import '../repositories/token_repository.dart';

class GoogleLoginAction {
  final GoogleAuthRepository googleRepository;
  final AuthRepository authRepository;
  final TokenRepository tokenRepository;

  GoogleLoginAction(
    this.googleRepository,
    this.authRepository,
    this.tokenRepository,
  );

  Future<LoginResult> execute() async {
    final serverCode = await googleRepository.getServerAuthCode();

    if (serverCode.isError()) {
      return LoginResult.canceled;
    }

    final authResult = await authRepository.googleLogin(
      serverCode.tryGetSuccess()!,
    );

    if (authResult.isError()) {
      return LoginResult.failure;
    }

    // store token
    final token = authResult.tryGetSuccess()!;
    tokenRepository.setToken(token);

    return LoginResult.success;
  }
}

enum LoginResult { success, needsRegistration, failure, canceled }
