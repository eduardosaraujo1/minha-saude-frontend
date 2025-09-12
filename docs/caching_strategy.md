# Caching Strategy

## Overview

This document outlines the simplified approach for caching data in the Minha Saúde application, with a focus on user profile data and other frequently accessed information.

## Principles

1. **Separation of Concerns**: Caching logic should be encapsulated within repositories
2. **Single Source of Truth**: Each data type has one authoritative source
3. **Time-Based Invalidation**: Cache is automatically invalidated after a specified period
4. **Explicit Refresh**: Critical operations should explicitly refresh cache
5. **Simplicity First**: Favor simplicity over complexity when it meets requirements

## Implementation

### Repository-Level In-Memory Caching

We implement caching at the repository level using only in-memory caching for simplicity:

1. **Memory Cache**: In-memory caching for fast access during app session
2. **Remote Source**: Network requests as the ultimate source of truth

Example for User Profile:

```dart
// lib/data/profile/repositories/user_profile_repository.dart
import 'package:minha_saude_frontend/domain/shared/models/user.dart';
import 'package:minha_saude_frontend/data/profile/sources/user_profile_remote_source.dart';

class UserProfileRepository {
  final UserProfileRemoteSource _remoteSource;

  // Memory cache
  User? _cachedProfile;
  DateTime? _lastFetchTime;

  // Cache expiration time (adjust as needed)
  final Duration _cacheValidity = const Duration(minutes: 15);

  UserProfileRepository(this._remoteSource);

  Future<User?> getUserProfile({bool forceRefresh = false}) async {
    // Return from memory cache if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid()) {
      return _cachedProfile;
    }

    // Fetch from remote if cache is invalid or forcing refresh
    try {
      final user = await _remoteSource.fetchUserProfile();
      if (user != null) {
        // Update memory cache
        _updateMemoryCache(user);
        return user;
      }
    } catch (e) {
      // If remote fetch fails but we have memory cache, return it
      if (_cachedProfile != null) {
        return _cachedProfile;
      }
      rethrow; // No data available
    }
    return null;
  }

  bool _isCacheValid() {
    return _cachedProfile != null &&
           _lastFetchTime != null &&
           DateTime.now().difference(_lastFetchTime!) < _cacheValidity;
  }

  void _updateMemoryCache(User user) {
    _cachedProfile = user;
    _lastFetchTime = DateTime.now();
  }

  Future<void> clearCache() async {
    _cachedProfile = null;
    _lastFetchTime = null;
  }

  // Other methods for updating profile, etc.
}
```

### Data Source

For each cacheable entity, we create a single remote data source:

```dart
// lib/data/profile/sources/user_profile_remote_source.dart
import 'package:http/http.dart' as http;
import 'package:minha_saude_frontend/domain/shared/models/user.dart';

class UserProfileRemoteSource {
  final http.Client _client;
  final String _baseUrl;

  UserProfileRemoteSource(this._client, this._baseUrl);

  Future<User?> fetchUserProfile() async {
    // Implementation for API calls
  }

  // Other remote operations
}
```

### Dependency Injection

Register these components in the providers setup:

```dart
// lib/providers/init.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:minha_saude_frontend/data/profile/repositories/user_profile_repository.dart';
import 'package:minha_saude_frontend/data/profile/sources/user_profile_remote_source.dart';

final getIt = GetIt.instance;

void initProviders() {
  // Core services
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Data sources
  getIt.registerLazySingleton<UserProfileRemoteSource>(
    () => UserProfileRemoteSource(
      getIt<http.Client>(),
      'https://api.minhasaude.com',
    ),
  );

  // Repositories
  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepository(
      getIt<UserProfileRemoteSource>(),
    ),
  );

  // Other providers...
}
```

## Usage in Presentation Layer

In the UI, you can access the cached data through the repository:

```dart
// lib/presentation/profile/views/profile_view.dart
import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/data/profile/repositories/user_profile_repository.dart';
import 'package:get_it/get_it.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final UserProfileRepository _profileRepo = GetIt.instance<UserProfileRepository>();
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      // Use cache by default
      final user = await _profileRepo.getUserProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error
    }
  }

  Future<void> _refreshProfile() async {
    setState(() => _isLoading = true);
    try {
      // Force refresh from remote
      final user = await _profileRepo.getUserProfile(forceRefresh: true);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error
    }
  }

  // Build UI...
}
```

## Cache Coordination

When data is updated, ensure related caches are invalidated:

1. When user logs out, clear all caches
2. When a profile field is updated, refresh the profile cache
3. For shared documents, refresh when new documents are added or existing ones are modified

## Considerations for Future Enhancements

### When to Consider Persistent Caching

If requirements change and you need any of these features, consider adding persistent caching:

1. **Offline support**: If users need to access data without internet
2. **Cold start performance**: If initial load time becomes problematic
3. **Battery/data conservation**: If reducing API calls becomes important

### Large Data Sets

For large collections like documents:

-   Implement pagination in the API
-   Cache each page in memory
-   Implement "infinite scroll" UIs with cached pages

### Real-time Data

For data that requires real-time updates:

-   Consider WebSocket connections instead of REST
-   Implement appropriate cache invalidation on real-time events
