import 'package:minha_saude_frontend/app/data/profile/models/user.dart';
import 'package:minha_saude_frontend/app/data/profile/sources/user_profile_remote_source.dart';

/// Implementation of the user profile repository with in-memory caching only
class UserProfileRepository {
  final UserProfileRemoteSource _remoteSource;

  // In-memory cache
  User? _cachedProfile;
  DateTime? _lastFetchTime;

  // Cache validity duration
  final Duration _cacheValidity;

  UserProfileRepository(this._remoteSource, {Duration? cacheValidity})
    : _cacheValidity = cacheValidity ?? const Duration(minutes: 15);

  Future<User?> getUserProfile({bool forceRefresh = false}) async {
    // Check memory cache if not forcing refresh
    if (!forceRefresh && _isCacheValid()) {
      return _cachedProfile;
    }

    // If cache is invalid or forcing refresh, fetch from API
    try {
      final user = await _remoteSource.fetchUserProfile();
      if (user != null) {
        // Update memory cache
        _updateMemoryCache(user);
      }
      return user;
    } catch (e) {
      // On error, try to return memory cache if available as fallback
      if (_cachedProfile != null) {
        return _cachedProfile;
      }
      // If no cached data available, propagate the error
      rethrow;
    }
  }

  Future<User?> updateUserField({
    required String field,
    required dynamic value,
  }) async {
    try {
      // Update via API
      final updatedUser = await _remoteSource.updateUserField(
        field: field,
        value: value,
      );

      if (updatedUser != null) {
        // Update memory cache
        _updateMemoryCache(updatedUser);
      }

      return updatedUser;
    } catch (e) {
      // Don't fall back to cache for update operations
      rethrow;
    }
  }

  Future<void> clearCache() async {
    _cachedProfile = null;
    _lastFetchTime = null;
  }

  // Helper to check if memory cache is still valid
  bool _isCacheValid() {
    return _cachedProfile != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidity;
  }

  // Helper to update memory cache
  void _updateMemoryCache(User user) {
    _cachedProfile = user;
    _lastFetchTime = DateTime.now();
  }
}
