import '../../../data/repositories/profile/profile_repository.dart';

class SettingsEditViewModel {
  SettingsEditViewModel({required this.type, required this.profileRepository});

  final EditFieldType type;
  final ProfileRepository profileRepository;
}

enum EditFieldType { name, phone, birthdate }
