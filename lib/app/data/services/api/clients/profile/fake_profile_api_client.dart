import 'package:intl/intl.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../fake/fake_server_cache_engine.dart';
import '../../fake/fake_server_database.dart';
import 'models/profile_api_model.dart';
import 'profile_api_client.dart';

class FakeProfileApiClient extends ProfileApiClient {
  FakeProfileApiClient({
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

  @override
  Future<Result<void, Exception>> deleteAccount() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final user = await _getCurrentUser();
      if (user == null) {
        return Error(Exception('No user found'));
      }

      final userId = user['id'] as int;
      await fakeServerDatabase.users.delete(userId);

      return Success(null);
    } catch (e) {
      return Error(Exception('Failed to delete account: $e'));
    }
  }

  @override
  Future<Result<ProfileApiModel, Exception>> getProfile() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      final user = await _getCurrentUser();
      if (user == null) {
        return Error(Exception('No user found'));
      }

      return Success(
        ProfileApiModel(
          id: user['id'].toString(),
          nome: user['nome'] as String,
          cpf: user['cpf'] as String,
          email: user['email'] as String,
          telefone: user['telefone'] as String? ?? '',
          dataNascimento: DateTime.parse(user['data_nascimento'] as String),
          metodoAutenticacao: user['metodo_autenticacao'] as String,
        ),
      );
    } catch (e) {
      return Error(Exception('Failed to get profile: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> linkGoogleAccount(String tokenOauth) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return Error(Exception('No user found'));
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

      return Success(null);
    } catch (e) {
      return Error(Exception('Failed to link Google account: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> requestPhoneVerificationCode(
    String phone,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Store fixed SMS code in cache
    fakeServerCacheEngine.put('sms_code_$phone', '100000');

    return Success(null);
  }

  @override
  Future<Result<String, Exception>> updateBirthdate(DateTime birthDate) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final user = await _getCurrentUser();
      if (user == null) {
        return Error(Exception('No user found'));
      }

      final userId = user['id'] as int;
      final dateString = DateFormat("yyyy-MM-dd").format(birthDate);
      await fakeServerDatabase.users.update(userId, {
        'data_nascimento': dateString,
      });

      return Success(dateString);
    } catch (e) {
      return Error(Exception('Failed to update birthdate: $e'));
    }
  }

  @override
  Future<Result<String, Exception>> updateName(String name) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final user = await _getCurrentUser();
      if (user == null) {
        return Error(Exception('No user found'));
      }

      final userId = user['id'] as int;
      await fakeServerDatabase.users.update(userId, {'nome': name});

      return Success(name);
    } catch (e) {
      return Error(Exception('Failed to update name: $e'));
    }
  }

  @override
  Future<Result<String, Exception>> updatePhone(String phone) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final user = await _getCurrentUser();
      if (user == null) {
        return Error(Exception('No user found'));
      }

      final userId = user['id'] as int;
      await fakeServerDatabase.users.update(userId, {'telefone': phone});

      return Success(phone);
    } catch (e) {
      return Error(Exception('Failed to update phone: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> verifyPhoneCode(String code) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // In fake implementation, we accept any code
    return Success(null);
  }

  @override
  Future<Result<void, Exception>> requestDataExport() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful data export request
    return Success(null);
  }
}
