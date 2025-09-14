import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minha_saude_frontend/app/data/profile/models/user.dart';

/// Local data source for user profile
/// Handles persistent caching of user profile data using secure storage
class UserProfileLocalSource {
  final FlutterSecureStorage _storage;

  // Storage keys
  static const String _userKey = 'cached_user_profile';
  static const String _cacheTimestampKey = 'user_profile_cache_timestamp';

  UserProfileLocalSource(this._storage);

  /// Get cached user profile with timestamp validation
  /// Returns null if cache is expired or doesn't exist
  Future<User?> getUser({Duration? maxAge}) async {
    try {
      final userData = await _storage.read(key: _userKey);
      final timestampStr = await _storage.read(key: _cacheTimestampKey);

      if (userData == null || timestampStr == null) {
        return null;
      }

      // Check cache age if maxAge is specified
      if (maxAge != null) {
        final timestamp = DateTime.parse(timestampStr);
        if (DateTime.now().difference(timestamp) > maxAge) {
          return null; // Cache expired
        }
      }

      return User.fromJsonString(userData);
    } catch (e) {
      // If any error occurs during reading/parsing, return null
      return null;
    }
  }

  /// Save user profile to persistent cache with current timestamp
  Future<void> saveUser(User user) async {
    try {
      await _storage.write(key: _userKey, value: user.toJsonString());
      await _storage.write(
        key: _cacheTimestampKey,
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Handle error (could log or rethrow based on requirements)
      rethrow;
    }
  }

  /// Clear cached user data
  Future<void> clearUser() async {
    try {
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _cacheTimestampKey);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Get cache timestamp
  Future<DateTime?> getCacheTimestamp() async {
    try {
      final timestampStr = await _storage.read(key: _cacheTimestampKey);
      if (timestampStr == null) return null;
      return DateTime.parse(timestampStr);
    } catch (e) {
      return null;
    }
  }
}
