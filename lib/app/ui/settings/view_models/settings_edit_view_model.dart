import 'package:command_it/command_it.dart';
import 'package:intl/intl.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../data/repositories/profile/profile_repository.dart';

class SettingsEditViewModel {
  SettingsEditViewModel({
    required this.fieldType,
    required this.profileRepository,
  }) {
    updateNameCommand = Command.createAsync(updateName, initialValue: null);
    updateBirthdateCommand = Command.createAsync(
      updateBirthdate,
      initialValue: null,
    );
    updatePhoneCommand = Command.createAsync(updatePhone, initialValue: null);

    loadCurrentValue = Command.createAsyncNoParam(
      _loadCurrentValue,
      initialValue: null,
    );
  }

  final ProfileRepository profileRepository;
  final SettingsEditField fieldType;

  late final Command<String, Result<void, Exception>?> updateNameCommand;
  late final Command<DateTime, Result<void, Exception>?> updateBirthdateCommand;
  late final Command<String, Result<void, Exception>?> updatePhoneCommand;
  late final Command<void, Result<String?, Exception>?> loadCurrentValue;

  Future<Result<void, Exception>> _runUpdateCommand(
    Future<Result<void, Exception>> Function() updateFunction,
  ) async {
    try {
      final result = await updateFunction.call();

      if (result.isError()) {
        return Error(Exception("Não foi possível atualizar o campo."));
      }

      return Success(null);
    } catch (e) {
      return Error(Exception("Não foi possível atualizar o campo."));
    }
  }

  Future<Result<void, Exception>> updateName(String name) async {
    final sanitized = name.trim().substring(0, name.length.clamp(0, 100));
    return _runUpdateCommand(() => profileRepository.updateName(sanitized));
  }

  Future<Result<void, Exception>> updateBirthdate(DateTime time) async =>
      _runUpdateCommand(() => profileRepository.updateBirthdate(time));

  Future<Result<void, Exception>> updatePhone(String phone) async {
    final sanitized = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return _runUpdateCommand(() => profileRepository.updatePhone(sanitized));
  }

  Future<Result<String, Exception>?> _loadCurrentValue() async {
    try {
      final result = await profileRepository.getProfile();

      if (result.isError()) {
        return Error(Exception("Não foi possível carregar o valor atual."));
      }
      final profile = result.tryGetSuccess()!;

      return switch (fieldType) {
        SettingsEditField.name => Success(profile.nome),
        SettingsEditField.birthdate => Success(
          DateFormat("dd/MM/yyyy").format(profile.dataNascimento),
        ),
        SettingsEditField.phone => Success(profile.telefone),
      };
    } catch (e) {
      return Error(Exception("Não foi possível carregar o valor atual."));
    }
  }
}

enum SettingsEditField { name, birthdate, phone }
