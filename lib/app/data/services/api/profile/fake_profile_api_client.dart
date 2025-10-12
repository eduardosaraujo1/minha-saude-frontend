import 'package:intl/intl.dart';
import 'package:multiple_result/multiple_result.dart';

import '../fakes/fake_server_persistent_storage.dart';
import 'models/profile_api_model.dart';
import 'profile_api_client.dart';

class FakeProfileApiClient extends ProfileApiClient {
  FakeProfileApiClient({required this.fakePersistentStorage});

  final FakeServerPersistentStorage fakePersistentStorage;

  @override
  Future<Result<void, Exception>> deleteAccount() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Delete the sole registered user
      await fakePersistentStorage.deleteUser();

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

      final user = await fakePersistentStorage.getUser();
      if (user == null) {
        return Error(Exception('No user found'));
      }

      return Success(
        ProfileApiModel(
          id: user.id,
          nome: user.nome,
          cpf: user.cpf,
          email: user.email,
          telefone: user.telefone,
          dataNascimento: user.dataNascimento,
          metodoAutenticacao: user.metodoAutenticacao.name,
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

    // Set local storage to indicate Google account is linked
    fakePersistentStorage.updateUserAuthMethod(InternalAuthMethod.google);

    // Simulate successful google account linking
    return Success(null);
  }

  @override
  Future<Result<void, Exception>> requestPhoneVerificationCode(
    String phone,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful verification code request
    return Success(null);
  }

  @override
  Future<Result<String, Exception>> updateBirthdate(DateTime birthDate) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      await fakePersistentStorage.updateUserBirthdate(birthDate);

      return Success(DateFormat("yyyy-MM-dd").format(birthDate));
    } catch (e) {
      return Error(Exception('Failed to update birthdate: $e'));
    }
  }

  @override
  Future<Result<String, Exception>> updateName(String name) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      await fakePersistentStorage.updateUserName(name);

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

      await fakePersistentStorage.updateUserPhone(phone);

      return Success(phone);
    } catch (e) {
      return Error(Exception('Failed to update phone: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> verifyPhoneCode(String code) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful code verification
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
