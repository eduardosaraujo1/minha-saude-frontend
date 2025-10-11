part of '../theme_provider.dart';

class _DarkTheme {
  static const seedColor = Color(0xFF003039);

  ThemeData theme() {
    return shared.applyOverrides(
      ThemeData(
        colorScheme: colorScheme(),
        brightness: Brightness.dark, //
      ),
    );
  }

  ColorScheme colorScheme() {
    final seededScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    // Override with .copyWith if needed
    return seededScheme;
  }
}
