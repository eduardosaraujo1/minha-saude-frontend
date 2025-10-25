import 'package:multiple_result/multiple_result.dart';

import '../../fake/fake_server_cache_engine.dart';
import '../../fake/fake_server_database.dart';
import 'models/login_response/login_api_response.dart';
import 'models/register_response/register_response.dart';
import 'auth_api_client.dart';

class FakeAuthApiClient implements AuthApiClient {
  FakeAuthApiClient({
    required this.fakeServerDatabase,
    required this.fakeServerCacheEngine,
  });

  final FakeServerDatabase fakeServerDatabase;
  final FakeServerCacheEngine fakeServerCacheEngine;

  @override
  Future<Result<LoginApiResponse, Exception>> authLoginGoogle(
    String tokenOauth,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate fake Google ID
    final googleId = DateTime.now().millisecondsSinceEpoch.toString().substring(
      0,
      10,
    );
    const email = 'eduardosaraujo100@gmail.com';

    // Check if user already exists with this email
    final existingUser = await fakeServerDatabase.users.findByEmail(email);

    if (existingUser != null) {
      // User already registered
      return Result.success(
        LoginApiResponse(
          isRegistered: true,
          sessionToken: 'fake_session_token',
          registerToken: null,
        ),
      );
    } else {
      // New user, create register token and cache the auth data
      final registerToken = _generateToken();
      fakeServerCacheEngine.put(registerToken, {
        'googleId': googleId,
        'email': email,
        'metodoAutenticacao': 'google',
      });

      return Result.success(
        LoginApiResponse(
          isRegistered: false,
          sessionToken: null,
          registerToken: registerToken,
        ),
      );
    }
  }

  @override
  Future<Result<RegisterResponse, Exception>> authRegister({
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String telefone,
    required String registerToken,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      // Get cached auth data
      final authData = fakeServerCacheEngine.get(registerToken);
      if (authData == null) {
        return Result.error(Exception('Invalid or expired registerToken'));
      }

      final email = authData['email'] as String;
      final metodoAutenticacao = authData['metodoAutenticacao'] as String;
      final googleId = authData['googleId'] as String?;

      // Check for duplicate CPF
      final existingByCpf = await fakeServerDatabase.users.findByCpf(cpf);
      if (existingByCpf != null) {
        return Result.error(Exception('CPF already registered'));
      }

      // Check for duplicate email
      final existingByEmail = await fakeServerDatabase.users.findByEmail(email);
      if (existingByEmail != null) {
        return Result.error(Exception('Email already registered'));
      }

      // Create user in database
      await fakeServerDatabase.users.create({
        'cpf': cpf,
        'nome': nome,
        'data_nascimento': dataNascimento.toIso8601String().split('T')[0],
        'telefone': telefone,
        'email': email,
        'metodo_autenticacao': metodoAutenticacao,
        'google_id': googleId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Clear the register token from cache
      fakeServerCacheEngine.delete(registerToken);

      return Result.success(
        RegisterResponse(status: 'success', sessionToken: 'fake_session_token'),
      );
    } catch (e) {
      return Result.error(Exception('Registration failed: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> authLogout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> authSendEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Store fixed verification code in cache
    fakeServerCacheEngine.put('email_code_$email', '100000');

    return Result.success(null);
  }

  @override
  Future<Result<LoginApiResponse, ApiEmailLoginException>> authLoginEmail(
    String email,
    String code,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Verify email code
    final storedCode = fakeServerCacheEngine.get('email_code_$email');
    if (storedCode == null) {
      return Result.error(
        ApiUnexpectedEmailLoginException(
          'No verification code found for this email',
        ),
      );
    }

    if (storedCode != code) {
      return Result.error(
        ApiEmailLoginIncorrectCodeException('Invalid verification code'),
      );
    }

    // Check if user already exists with this email
    final existingUser = await fakeServerDatabase.users.findByEmail(email);

    if (existingUser != null) {
      // User already registered
      return Result.success(
        LoginApiResponse(
          isRegistered: true,
          sessionToken: 'fake_session_token',
          registerToken: null,
        ),
      );
    } else {
      // New user, create register token and cache the auth data
      final registerToken = _generateToken();
      fakeServerCacheEngine.put(registerToken, {
        'email': email,
        'metodoAutenticacao': 'email',
      });

      return Result.success(
        LoginApiResponse(isRegistered: false, registerToken: registerToken),
      );
    }
  }

  /// Generate a random token for session or register tokens
  String _generateToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode;
    return 'fake_token_${timestamp}_$random';
  }
}
