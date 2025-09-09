import 'package:minha_saude_frontend/domain/profile/repositories/user_profile_repository.dart';
import 'package:minha_saude_frontend/domain/shared/models/user.dart';

/// Example usage of the user profile repository in a presentation layer ViewModel
class ProfileViewModel {
  final IUserProfileRepository _userProfileRepository;

  User? _currentProfile;
  bool _isLoading = false;
  String? _error;

  // Constructor
  ProfileViewModel(this._userProfileRepository);

  // Getters for state
  User? get profile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load user profile, optionally forcing a refresh
  Future<void> loadProfile({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;

    try {
      final user = await _userProfileRepository.getUserProfile(
        forceRefresh: forceRefresh,
      );
      _currentProfile = user;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  /// Update a specific field in the user profile
  Future<bool> updateField({
    required String field,
    required dynamic value,
  }) async {
    _isLoading = true;
    _error = null;

    try {
      final updatedUser = await _userProfileRepository.updateUserField(
        field: field,
        value: value,
      );

      if (updatedUser != null) {
        _currentProfile = updatedUser;
        return true;
      } else {
        _error = 'Failed to update profile';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
}
