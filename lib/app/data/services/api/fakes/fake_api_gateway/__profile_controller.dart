part of 'fake_api_gateway.dart';

class _ProfileController {
  _ProfileController({
    required this.fakeServerDatabase,
    required this.fakeServerCacheEngine,
  });

  final FakeServerDatabase fakeServerDatabase;
  final FakeServerCacheEngine fakeServerCacheEngine;

  // Helper to get the current user (in fake, we just use the first user)
  Future<Map<String, dynamic>?> _getCurrentUser() async {
    final users = await fakeServerDatabase.users.readAll();
    return users.isEmpty ? null : users.first;
  }

  /// GET /profile - Get user profile data
  ///
  /// Response: `{id: int, nome: String, cpf: String, email: String, telefone: String?, dataNascimento: String (YYYY-MM-DD), metodoAutenticacao: String (email | google)}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>>
  getUserProfile() async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ClientException('User not found'));
      }

      return Success({
        'id': user['id'],
        'nome': user['nome'],
        'cpf': user['cpf'],
        'email': user['email'],
        'telefone': user['telefone'],
        'dataNascimento': user['data_nascimento'],
        'metodoAutenticacao': user['metodo_autenticacao'],
      });
    } catch (e) {
      return Error(ServerException('Failed to get user profile: $e'));
    }
  }

  /// PUT /profile/name - Edit user name
  ///
  /// Data: `{nome: String}`
  ///
  /// Response: `{id: int, nome: String}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> editName({
    required Map<String, dynamic> data,
  }) async {
    try {
      final nome = data['nome'] as String?;
      if (nome == null) {
        return Error(ClientException('Missing nome'));
      }

      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ClientException('User not found'));
      }

      final userId = user['id'] as int;
      await fakeServerDatabase.users.update(userId, {'nome': nome});

      return Success({'id': userId, 'nome': nome});
    } catch (e) {
      return Error(ServerException('Failed to edit name: $e'));
    }
  }

  /// PUT /profile/birthdate - Edit user birthdate
  ///
  /// Data: `{dataNascimento: String (YYYY-MM-DD)}`
  ///
  /// Response: `{id: int, dataNascimento: String (YYYY-MM-DD)}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> editBirthdate({
    required Map<String, dynamic> data,
  }) async {
    try {
      final dataNascimento = data['dataNascimento'] as String?;
      if (dataNascimento == null) {
        return Error(ClientException('Missing dataNascimento'));
      }

      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ClientException('User not found'));
      }

      final userId = user['id'] as int;
      await fakeServerDatabase.users.update(userId, {
        'data_nascimento': dataNascimento,
      });

      return Success({'id': userId, 'dataNascimento': dataNascimento});
    } catch (e) {
      return Error(ServerException('Failed to edit birthdate: $e'));
    }
  }

  /// PUT /profile/phone - Edit phone number (requires SMS verification)
  ///
  /// Data: `{telefone: String, codigoSms: String}`
  ///
  /// Response: `{id: int, telefone: String}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> editPhone({
    required Map<String, dynamic> data,
  }) async {
    try {
      final telefone = data['telefone'] as String?;
      final codigoSms = data['codigoSms'] as String?;

      if (telefone == null || codigoSms == null) {
        return Error(ClientException('Missing telefone or codigoSms'));
      }

      // Verify SMS code
      final storedCode = fakeServerCacheEngine.get('sms_code_$telefone');
      if (storedCode == null || storedCode != codigoSms) {
        return Error(ClientException('Invalid SMS code'));
      }

      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ClientException('User not found'));
      }

      final userId = user['id'] as int;
      await fakeServerDatabase.users.update(userId, {'telefone': telefone});

      // Clear the SMS code
      fakeServerCacheEngine.delete('sms_code_$telefone');

      return Success({'id': userId, 'telefone': telefone});
    } catch (e) {
      return Error(ServerException('Failed to edit phone: $e'));
    }
  }

  /// POST /profile/phone/send-sms - Send SMS verification code
  ///
  /// Data: `{telefone: String}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> sendPhoneSms({
    required Map<String, dynamic> data,
  }) async {
    try {
      final telefone = data['telefone'] as String?;
      if (telefone == null) {
        return Error(ClientException('Missing telefone'));
      }

      // Store fixed SMS code in cache
      fakeServerCacheEngine.put('sms_code_$telefone', '100000');

      return Success({'status': 'success', 'message': null});
    } catch (e) {
      return Error(ServerException('Failed to send SMS: $e'));
    }
  }

  /// POST /profile/google/link - Link Google account
  ///
  /// Data: `{tokenOauth: String}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> linkGoogleAccount({
    required Map<String, dynamic> data,
  }) async {
    try {
      final tokenOauth = data['tokenOauth'] as String?;
      if (tokenOauth == null) {
        return Error(ClientException('Missing tokenOauth'));
      }

      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ClientException('User not found'));
      }

      // Generate fake Google ID
      final googleId = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(0, 10);

      final userId = user['id'] as int;
      await fakeServerDatabase.users.update(userId, {
        'google_id': googleId,
        'metodo_autenticacao': 'google',
      });

      return Success({'status': 'success', 'message': null});
    } catch (e) {
      return Error(ServerException('Failed to link Google account: $e'));
    }
  }

  /// DELETE /profile - Schedule account deletion
  ///
  /// Data: `{authType: String (email | google), auth: {email: String?, codigoEmail: String?, tokenOauth: String?}}`
  ///
  /// Response: `{status: String (success | error)}`
  Future<Result<Map<String, dynamic>, ApiGatewayException>> deleteAccount({
    required Map<String, dynamic> data,
  }) async {
    try {
      final authType = data['authType'] as String?;
      final auth = data['auth'] as Map<String, dynamic>?;

      if (authType == null || auth == null) {
        return Error(ClientException('Missing authType or auth'));
      }

      // In fake implementation, skip actual auth verification
      final user = await _getCurrentUser();
      if (user == null) {
        return Error(ClientException('User not found'));
      }

      final userId = user['id'] as int;
      await fakeServerDatabase.users.delete(userId);

      return Success({'status': 'success'});
    } catch (e) {
      return Error(ServerException('Failed to delete account: $e'));
    }
  }
}
