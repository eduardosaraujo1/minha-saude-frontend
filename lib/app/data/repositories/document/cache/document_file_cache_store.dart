import 'dart:io';

class DocumentFileCacheStore {
  String? _cachedUuid;
  File? _cachedFile;

  /// Returns the cached file if the UUID matches, otherwise null
  File? get(String uuid) {
    if (_cachedUuid == uuid && _cachedFile != null) {
      return _cachedFile;
    }
    return null;
  }

  /// Stores a file and its UUID in the cache
  void set(String uuid, File file) {
    _cachedUuid = uuid;
    _cachedFile = file;
  }

  /// Clears the cache
  void clear() {
    _cachedUuid = null;
    _cachedFile = null;
  }
}
