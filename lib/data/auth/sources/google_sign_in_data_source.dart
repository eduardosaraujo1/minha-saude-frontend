/*
# shared
Gateway -> usado pra falar com o backend, funções como "sendRequest" etc
Session -> Armazena se o usuário está logado ou não em FlutterSecureStorage e localmente, permite efetuar "login(LoginStrategy)", "logout", e pegar o usuário atualmente logado
(abstract) AuthStrategy
# features/auth
## data
sources/AuthLocalDataSource -> Responsável por gerenciar a autenticação local, como armazenamento de token, login e logout.
sources/AuthRemoteDataSource -> Responsável por gerenciar a autenticação remota, como troca de tokens.
repositories/AuthRepositoryImpl -> Decide qual API usar para gerar auth token

## domain
repositories/AuthRepository
abstract LoginStrategy -> Criar implementações como GoogleLogin e EmailLogin, com os dados necessários no objeto em si (substituir GoogleAuthService por isso aqui)
model AuthUser -> Dados do usuário autenticado
 */
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/data/auth/sources/google_auth_config.dart';
import 'package:multiple_result/multiple_result.dart';

class GoogleSignInDataSource {
  static const List<String> scopes = <String>[
    'https://www.googleapis.com/auth/userinfo.email',
    'openid',
  ];

  final GoogleSignIn _signIn;

  const GoogleSignInDataSource._(this._signIn);

  static Future<GoogleSignInDataSource> create(
    GoogleSignIn signIn,
    GoogleAuthConfig config,
  ) async {
    await signIn.initialize(
      clientId: config.clientId,
      serverClientId: config.serverClientId,
    );

    return GoogleSignInDataSource._(signIn);
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
