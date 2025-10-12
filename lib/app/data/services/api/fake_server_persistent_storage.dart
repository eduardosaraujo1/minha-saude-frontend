import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FakeServerPersistentStorage {
  FakeServerPersistentStorage() {
    _init();
  }

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  bool? _isRegistered;

  Future<void> setRegistered(bool value) async {
    _isRegistered = value;

    // Update SecureStorage
    _secureStorage.write(key: 'is_registered', value: value ? 'true' : 'false');
  }

  Future<bool> getRegistered({bool forceRefresh = false}) async {
    if (forceRefresh || _isRegistered == null) {
      await _init();
    }
    return _isRegistered ?? false;
  }

  Future<void> _init() async {
    final val = await _secureStorage.read(key: 'is_registered');
    _isRegistered = (val == 'true');
  }
}
