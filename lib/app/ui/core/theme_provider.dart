import 'package:flutter/material.dart';

import 'themes/shared.dart' as shared;
part 'themes/light_theme.dart';
part 'themes/dark_theme.dart';

/// Controller for managing theme state across the app
class ThemeController {
  ThemeController({ThemeMode initialMode = ThemeMode.system})
    : mode = ValueNotifier(initialMode);

  final ThemeData lightTheme = _LightTheme().theme();
  final ThemeData darkTheme = _DarkTheme().theme();
  final ValueNotifier<ThemeMode> mode;

  void enableDarkMode() {
    if (mode.value == ThemeMode.dark) return;
    mode.value = ThemeMode.dark;
  }

  void enableLightMode() {
    if (mode.value == ThemeMode.light) return;
    mode.value = ThemeMode.light;
  }

  void toggleTheme() {
    if (mode.value == ThemeMode.dark) {
      enableLightMode();
    } else {
      enableDarkMode();
    }
  }

  void dispose() {
    mode.dispose();
  }
}

/// InheritedWidget that provides theme controller to descendants
class ThemeProvider extends InheritedWidget {
  const ThemeProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  final ThemeController controller;

  static ThemeController of(BuildContext context) {
    final ThemeProvider? provider = context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>();

    if (provider == null) {
      throw FlutterError(
        'ThemeProvider.of() called with a context that does not contain a ThemeProvider.\n'
        'No ThemeProvider ancestor could be found starting from the context that was passed to ThemeProvider.of().\n'
        'The context used was:\n'
        '  $context',
      );
    }

    return provider.controller;
  }

  static ThemeController? maybeOf(BuildContext context) {
    final ThemeProvider? provider = context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>();
    return provider?.controller;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
