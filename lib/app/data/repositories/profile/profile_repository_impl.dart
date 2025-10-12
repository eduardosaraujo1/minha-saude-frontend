import 'package:minha_saude_frontend/app/domain/models/profile/profile.dart';

import 'package:multiple_result/multiple_result.dart';

import '../../services/api/profile/profile_api_client.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  ProfileRepositoryImpl({
    required this.profileApiClient, //
  });

  final ProfileApiClient profileApiClient;

  @override
  Future<Result<void, Exception>> deleteAccount() {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<Result<Profile, Exception>> getProfile({forceRefresh = false}) {
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
  Future<Result<void, Exception>> requestDataExport() {
    // TODO: implement requestDataExport
    throw UnimplementedError();
  }
}
