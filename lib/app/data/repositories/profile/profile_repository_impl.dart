import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/domain/models/profile/profile.dart';

import 'package:multiple_result/multiple_result.dart';

import '../../services/api/profile/profile_api_client.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  ProfileRepositoryImpl({
    required this.profileApiClient, //
  });

  final ProfileApiClient profileApiClient;
  final _InMemoryProfileCache _cache = _InMemoryProfileCache();

  final Logger _logger = Logger('ProfileRepositoryImpl');

  @override
  Future<Result<void, Exception>> deleteAccount() {
    return _wrapException(() async {
      final apiResult = await profileApiClient.deleteAccount();

      if (apiResult.isError()) {
        _logger.warning("Delete Account API Error: ", apiResult.tryGetError()!);
        return Error(Exception("Failed to delete account"));
      }

      _cache.clear();

      return Success(null);
    });
  }

  @override
  Future<Result<Profile, Exception>> getProfile({forceRefresh = false}) {
    return _wrapException<Profile>(() async {
      if (!forceRefresh && _cache.profile != null) {
        return Success(_cache.profile!);
      }

      final apiResult = await profileApiClient.getProfile();

      if (apiResult.isError()) {
        _logger.warning("Profile API Error: ", apiResult.tryGetError()!);
        return Error(Exception("Failed to fetch profile data"));
      }

      final profileApiModel = apiResult.tryGetSuccess()!;
      var metodoAutenticacao = switch (profileApiModel.metodoAutenticacao
          .trim()
          .toLowerCase()) {
        'email' => AuthMethod.email,
        'google' => AuthMethod.google,
        _ => AuthMethod.email,
      };

      final profile = Profile(
        id: profileApiModel.id,
        nome: profileApiModel.nome,
        cpf: profileApiModel.cpf,
        email: profileApiModel.email,
        telefone: profileApiModel.telefone,
        dataNascimento: profileApiModel.dataNascimento,
        metodoAutenticacao: metodoAutenticacao,
      );

      _cache.set(profile);

      return Success(profile);
    });
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

  Future<Result<T, Exception>> _wrapException<T>(
    Future<Result<T, Exception>> Function() func,
  ) async {
    try {
      return await func();
    } catch (e, s) {
      _logger.severe('Error in ProfileRepositoryImpl', e, s);
      return Error(Exception('Ocorreu um erro inesperado'));
    }
  }
}

class _InMemoryProfileCache {
  Profile? profile;

  void clear() {
    profile = null;
  }

  void set(Profile profile) {
    this.profile = profile;
  }

  void updateName(String name) {
    if (profile != null) {
      profile = profile!.copyWith(nome: name);
    }
  }

  void updatePhone(String phone) {
    if (profile != null) {
      profile = profile!.copyWith(telefone: phone);
    }
  }

  void updateBirthdate(DateTime birthDate) {
    if (profile != null) {
      profile = profile!.copyWith(dataNascimento: birthDate);
    }
  }
}
