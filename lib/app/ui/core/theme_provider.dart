import 'package:flutter/material.dart';

part 'themes/light_theme.dart';
part 'themes/dark_theme.dart';

class ThemeProvider {
  ThemeProvider();

  final ThemeData lightTheme = _LightTheme().theme();
  final ThemeData darkTheme = _DarkTheme().theme();
  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  void enableDarkMode() {
    if (mode.value == ThemeMode.dark) return;

    mode.value = ThemeMode.dark;
  }

  void enableLightMode() {
    if (mode.value == ThemeMode.light) return;

    mode.value = ThemeMode.light;
  }
}
