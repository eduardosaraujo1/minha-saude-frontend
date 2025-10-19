import 'dart:collection';

import '../../../../domain/models/document/document.dart';

class DocumentListCacheStore {
  static const Duration ttl = Duration(minutes: 10);

  List<Document>? _documents;
  DateTime? _timestamp;

  /// Stores a new list in the cache
  /// Resets cache age
  void set(List<Document> documents) {
    _documents ??= [];
    _documents!.clear();
    _documents!.addAll(documents);
    _timestamp = DateTime.now();
  }

  /// Clears the cache
  /// Also resets cache age
  void clear() {
    _timestamp = null;
    _documents = null;
  }

  /// Returns the cached list if it exists, otherwise null
  /// Does not return stale data, forcing a cache miss
  List<Document>? get() {
    return isValid() ? UnmodifiableListView(_documents!) : null;
  }

  /// Retrieves a document by UUID from the cache if available
  /// Returns null if not found or cache is invalid
  Document? getByUuid(String uuid) {
    if (!isValid()) {
      return null;
    }

    try {
      return _documents!.firstWhere((doc) => doc.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  /// Returns true if the cache exists and is not stale
  bool isValid() {
    if (_documents == null) {
      return false;
    }

    if (_timestamp == null) {
      return false;
    }

    final age = DateTime.now().difference(_timestamp!);

    if (age > ttl) {
      return false;
    }

    return true;
  }
}
