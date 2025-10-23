class FakeServerCacheEngine {
  final Map<String, dynamic> _cache = {};

  dynamic get(String key) {
    return _cache[key];
  }

  void put(String key, dynamic value) {
    _cache[key] = value;
  }

  void delete(String key) {
    _cache.remove(key);
  }
}
