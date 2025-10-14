part of '../theme_provider.dart';

class _LightTheme {
  static const seedColor = Color(0xFF003039);

  ThemeData theme() {
    return shared.applyOverrides(
      ThemeData(
        colorScheme: colorScheme(),
        brightness: Brightness.light, //
      ),
    );
  }

  ColorScheme colorScheme() {
    final seededScheme = ColorScheme.fromSeed(seedColor: seedColor);

    // Override with .copyWith if needed
    return seededScheme;
  }
}
