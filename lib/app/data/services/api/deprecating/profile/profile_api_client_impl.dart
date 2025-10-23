import 'package:multiple_result/multiple_result.dart';

import '../http_client/http_client.dart';
import 'models/profile_api_model.dart';
import 'profile_api_client.dart';

class ProfileApiClientImpl extends ProfileApiClient {
  ProfileApiClientImpl(this.httpClient);

  final LegacyHttpClient httpClient;

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
  Future<Result<void, Exception>> requestDataExport() {
    // TODO: implement requestDataExport
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> requestPhoneVerificationCode(String phone) {
    // TODO: implement requestPhoneVerificationCode
    throw UnimplementedError();
  }

  @override
  Future<Result<String, Exception>> updateBirthdate(DateTime birthDate) {
    // TODO: implement updateBirthdate
    throw UnimplementedError();
  }

  @override
  Future<Result<String, Exception>> updateName(String name) {
    // TODO: implement updateName
    throw UnimplementedError();
  }

  @override
  Future<Result<String, Exception>> updatePhone(String phone) {
    // TODO: implement updatePhone
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> verifyPhoneCode(String code) {
    // TODO: implement verifyPhoneCode
    throw UnimplementedError();
  }
}
