import 'package:minha_saude_frontend/domain/shared/models/user.dart';

/// Interface for the user profile repository
abstract class IUserProfileRepository {
  /// Get the user profile
  ///
  /// If [forceRefresh] is true, the cache will be ignored and
  /// a fresh copy will be fetched from the remote source
  Future<User?> getUserProfile({bool forceRefresh = false});

  /// Update a specific field in the user profile
  Future<User?> updateUserField({
    required String field,
    required dynamic value,
  });

  /// Clear cached profile data
  Future<void> clearCache();
}
