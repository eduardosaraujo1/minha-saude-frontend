import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/profile/profile.dart';
import '../../services/api/deprecating/profile/profile_api_client.dart';
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
      notifyListeners();

      return Success(null);
    });
  }

  @override
  Future<Result<Profile, Exception>> getProfile({bool forceRefresh = false}) {
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
    return _wrapException(() async {
      final apiResult = await profileApiClient.linkGoogleAccount(tokenOauth);

      if (apiResult.isError()) {
        _logger.warning(
          "Link Google Account API Error: ",
          apiResult.tryGetError()!,
        );
        return Error(Exception("Failed to link Google account"));
      }

      // Update local cache if exists
      _cache.updateAuthMethod(AuthMethod.google);
      notifyListeners();

      return Success(null);
    });
  }

  @override
  Future<Result<void, Exception>> requestPhoneVerificationCode(String phone) {
    return _wrapException(() async {
      final apiResult = await profileApiClient.requestPhoneVerificationCode(
        phone,
      );

      if (apiResult.isError()) {
        _logger.warning(
          "Request Phone Verification Code API Error: ",
          apiResult.tryGetError()!,
        );
        return Error(Exception("Failed to request phone verification code"));
      }

      return Success(null);
    });
  }

  @override
  Future<Result<void, Exception>> updateBirthdate(DateTime birthDate) {
    return _wrapException(() async {
      final apiResult = await profileApiClient.updateBirthdate(birthDate);

      if (apiResult.isError()) {
        _logger.warning(
          "Update Birthdate API Error: ",
          apiResult.tryGetError()!,
        );
        return Error(Exception("Failed to update birthdate"));
      }

      final updatedBirthdateStr = apiResult.tryGetSuccess()!;
      final updatedBirthdate = DateFormat(
        "yyyy-MM-dd",
      ).tryParse(updatedBirthdateStr);

      if (updatedBirthdate == null) {
        _logger.warning(
          "Failed to parse updated birthdate: $updatedBirthdateStr - falling back to cache invalidation",
        );
        _cache.clear();
        return Success(null);
      }

      // Update local cache if exists
      _cache.updateBirthdate(updatedBirthdate);
      notifyListeners();

      return Success(null);
    });
  }

  @override
  Future<Result<void, Exception>> updateName(String name) {
    return _wrapException(() async {
      // Truncate to 100 characters and remove leading/trailing whitespace
      final sanitized = name.trim().substring(0, name.length.clamp(0, 100));
      final apiResult = await profileApiClient.updateName(sanitized);

      if (apiResult.isError()) {
        _logger.warning("Update Name API Error: ", apiResult.tryGetError()!);
        return Error(Exception("Failed to update name"));
      }

      final updatedName = apiResult.tryGetSuccess()!;

      // Update local cache if exists
      _cache.updateName(updatedName);
      notifyListeners();

      return Success(null);
    });
  }

  @override
  Future<Result<void, Exception>> updatePhone(String phone) {
    return _wrapException(() async {
      // Clean phone number to only digits
      phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

      final apiResult = await profileApiClient.updatePhone(phone);

      if (apiResult.isError()) {
        _logger.warning("Update Phone API Error: ", apiResult.tryGetError()!);
        return Error(Exception("Failed to update phone"));
      }

      final updatedPhone = apiResult.tryGetSuccess()!;

      // Update local cache if exists
      _cache.updatePhone(updatedPhone);
      notifyListeners();

      return Success(null);
    });
  }

  @override
  Future<Result<void, Exception>> verifyPhoneCode(String code) {
    return _wrapException(() async {
      final apiResult = await profileApiClient.verifyPhoneCode(code);

      if (apiResult.isError()) {
        // TODO: desenvolver arquitetura para diferenciar erros tecnicos
        //(404, 500, timeout) de erros de negocio (codigo invalido, codigo expirado)
        _logger.fine("Verify Phone Code API error: ", apiResult.tryGetError()!);
        return Error(Exception("Failed to verify phone code"));
      }

      return Success(null);
    });
  }

  @override
  Future<Result<void, Exception>> requestDataExport() {
    return _wrapException(() async {
      final apiResult = await profileApiClient.requestDataExport();

      if (apiResult.isError()) {
        _logger.warning(
          "Request Data Export API Error: ",
          apiResult.tryGetError()!,
        );
        return Error(Exception("Failed to request data export"));
      }

      return Success(null);
    });
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

  @override
  Future<void> clearCache() async {
    _cache.clear();
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

  void updateAuthMethod(AuthMethod method) {
    if (profile != null) {
      profile = profile!.copyWith(metodoAutenticacao: method);
    }
  }
}
