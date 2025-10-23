part of 'fake_api_gateway.dart';

class _AuthController {
  _AuthController({
    required this.fakeServerCacheEngine,
    required this.fakeServerDatabase,
  });
  final FakeServerCacheEngine fakeServerCacheEngine;
  final FakeServerDatabase fakeServerDatabase;

  /// POST /auth/login/google - Login with Google
  ///
  /// Data: `{tokenOauth: String}`
  ///
  /// Response: `{isRegistered: bool, sessionToken: String?, registerToken: String?}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> loginGoogle({
    required Map<String, dynamic> data,
  }) async {
    try {
      final tokenOauth = data['tokenOauth'] as String?;
      if (tokenOauth == null) {
        return Error(ClientException('Missing tokenOauth'));
      }

      // Generate fake Google ID (10 digit number)
      final googleId = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(0, 10);
      const email = 'eduardosaraujo100@gmail.com';

      // Check if user already exists with this email
      final existingUser = await fakeServerDatabase.users.findByEmail(email);

      if (existingUser != null) {
        // User already registered, generate session token
        final sessionToken = _generateToken();
        return Success({
          'isRegistered': true,
          'sessionToken': sessionToken,
          'registerToken': null,
        });
      }

      // New user, create register token and cache the auth data
      final registerToken = _generateToken();
      fakeServerCacheEngine.put(registerToken, {
        'googleId': googleId,
        'email': email,
        'metodoAutenticacao': 'google',
      });

      return Success({
        'isRegistered': false,
        'sessionToken': null,
        'registerToken': registerToken,
      });
    } catch (e) {
      return Error(ClientException('Login with Google failed: $e'));
    }
  }

  /// POST /auth/login/email - Login with Email
  ///
  /// Data: `{email: String, codigoEmail: String}`
  ///
  /// Response: `{isRegistered: bool, sessionToken: String?, registerToken: String?}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> loginEmail({
    required Map<String, dynamic> data,
  }) async {
    try {
      final email = data['email'] as String?;
      final codigoEmail = data['codigoEmail'] as String?;

      if (email == null || codigoEmail == null) {
        return Error(ClientException('Missing email or codigoEmail'));
      }

      // Verify email code (skip actual verification in fake, just check it exists)
      final storedCode = fakeServerCacheEngine.get('email_code_$email');
      if (storedCode == null) {
        return Error(
          ClientException('No verification code found for this email'),
        );
      }

      if (storedCode != codigoEmail) {
        return Error(ClientException('Invalid verification code'));
      }

      // Check if user already exists with this email
      final existingUser = await fakeServerDatabase.users.findByEmail(email);

      if (existingUser != null) {
        // User already registered, generate session token
        final sessionToken = _generateToken();
        return Success({
          'isRegistered': true,
          'sessionToken': sessionToken,
          'registerToken': null,
        });
      }

      // New user, create register token and cache the auth data
      final registerToken = _generateToken();
      fakeServerCacheEngine.put(registerToken, {
        'email': email,
        'metodoAutenticacao': 'email',
      });

      return Success({
        'isRegistered': false,
        'sessionToken': null,
        'registerToken': registerToken,
      });
    } catch (e) {
      return Error(ClientException('Login with email failed: $e'));
    }
  }

  /// POST /auth/register - Register a new user
  ///
  /// Data: `{user: {nome: String, cpf: String, dataNascimento: String (YYYY-MM-DD), telefone: String?}, registerToken: String}`
  ///
  /// Response: `{sessionToken: String?}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> register({
    required Map<String, dynamic> data,
  }) async {
    try {
      final user = data['user'] as Map<String, dynamic>?;
      final registerToken = data['registerToken'] as String?;

      if (user == null || registerToken == null) {
        return Error(ClientException('Missing user or registerToken'));
      }

      // Validate required user fields
      final nome = user['nome'] as String?;
      final cpf = user['cpf'] as String?;
      final dataNascimento = user['dataNascimento'] as String?;

      if (nome == null || cpf == null || dataNascimento == null) {
        return Error(
          ClientException(
            'Missing required user fields: nome, cpf, dataNascimento',
          ),
        );
      }

      // Get cached auth data
      final authData = fakeServerCacheEngine.get(registerToken);
      if (authData == null) {
        return Error(ClientException('Invalid or expired registerToken'));
      }

      final email = authData['email'] as String;
      final metodoAutenticacao = authData['metodoAutenticacao'] as String;
      final googleId = authData['googleId'] as String?;

      // Check for duplicate CPF
      final existingByCpf = await fakeServerDatabase.users.findByCpf(cpf);
      if (existingByCpf != null) {
        return Error(ClientException('CPF already registered'));
      }

      // Check for duplicate email
      final existingByEmail = await fakeServerDatabase.users.findByEmail(email);
      if (existingByEmail != null) {
        return Error(ClientException('Email already registered'));
      }

      // Create user in database
      await fakeServerDatabase.users.create({
        'cpf': cpf,
        'nome': nome,
        'data_nascimento': dataNascimento,
        'telefone': user['telefone'] as String?,
        'email': email,
        'metodo_autenticacao': metodoAutenticacao,
        'google_id': googleId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Generate session token
      final sessionToken = _generateToken();

      // Clear the register token from cache
      fakeServerCacheEngine.delete(registerToken);

      return Success({'sessionToken': sessionToken});
    } catch (e) {
      return Error(ClientException('Registration failed: $e'));
    }
  }

  /// POST /auth/logout - Invalidate current token
  ///
  /// Data: `{}`
  ///
  /// Response: `{status: String (success | error)}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> logout() async {
    // In fake implementation, we don't actually track session tokens
    // Just return success
    return Success({'status': 'success'});
  }

  /// POST /auth/send-email - Send email verification code for login
  ///
  /// Data: `{email: String}`
  ///
  /// Response: `{status: String (success | error)}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> sendEmail({
    required Map<String, dynamic> data,
  }) async {
    try {
      final email = data['email'] as String?;
      if (email == null) {
        return Error(ClientException('Missing email'));
      }

      // Store fixed verification code in cache
      fakeServerCacheEngine.put('email_code_$email', '100000');

      return Success({'status': 'success'});
    } catch (e) {
      return Error(ClientException('Failed to send email: $e'));
    }
  }

  /// Generate a random token for session or register tokens
  String _generateToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode;
    return 'fake_token_${timestamp}_$random';
  }
}
