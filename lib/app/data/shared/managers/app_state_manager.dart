import 'package:flutter/foundation.dart';

/// Global state manager for app initialization and connection status
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  bool _hasStartupConnectionError = false;
  Exception? _startupError;

  bool get hasStartupConnectionError => _hasStartupConnectionError;
  Exception? get startupError => _startupError;

  void setStartupConnectionError(Exception error) {
    _hasStartupConnectionError = true;
    _startupError = error;
    notifyListeners();
  }

  void clearStartupConnectionError() {
    _hasStartupConnectionError = false;
    _startupError = null;
    notifyListeners();
  }
}
