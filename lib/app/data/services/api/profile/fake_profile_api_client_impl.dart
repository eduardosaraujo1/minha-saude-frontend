import 'package:multiple_result/multiple_result.dart';

import '../fake_server_persistent_storage.dart';
import 'models/profile_api_model.dart';
import 'profile_api_client.dart';

class FakeProfileApiClient extends ProfileApiClient {
  FakeProfileApiClient({required this.fakePersistentStorage});

  final FakeServerPersistentStorage fakePersistentStorage;

  @override
  Future<Result<void, Exception>> deleteAccount() {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<Result<ProfileApiModel, Exception>> getProfile() {
    // TODO: implement getProfile
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> linkGoogleAccount(String tokenOauth) {
    // TODO: implement linkGoogleAccount
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> requestPhoneVerificationCode(String phone) {
    // TODO: implement requestPhoneVerificationCode
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> updateBirthdate(DateTime birthDate) {
    // TODO: implement updateBirthdate
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> updateName(String name) {
    // TODO: implement updateName
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> updatePhone(String phone) {
    // TODO: implement updatePhone
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> verifyPhoneCode(String code) {
    // TODO: implement verifyPhoneCode
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> requestDataExport() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful data export request
    return Success(null);
  }
}
