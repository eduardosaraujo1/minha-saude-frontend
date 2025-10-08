part of '../theme_provider.dart';

class _DarkTheme {
  static const seedColor = Color(0xFF003039);

  ThemeData theme() {
    final scheme = colorScheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceBright,
      snackBarTheme: snackBarTheme(),
    );
  }

  SnackBarThemeData snackBarTheme() {
    final scheme = colorScheme();

    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      actionTextColor: scheme.inversePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  ColorScheme colorScheme() {
    final seededScheme = ColorScheme.fromSeed(seedColor: seedColor);

    return seededScheme.copyWith(
      brightness: Brightness.dark,
      // primary: Color(0xFF84D2E6),
      // onPrimary: Color(0xFF003640),
      // primaryContainer: Color(0xFF004E5C),
      // onPrimaryContainer: Color(0xFFA9EDFF),
      // secondary: Color(0xFFB2CBD2),
      // onSecondary: Color(0xFF1D343A),
      // secondaryContainer: Color(0xFF334A50),
      // onSecondaryContainer: Color(0xFFCEE7EE),
      // tertiary: Color(0xFFBEC5EB),
      // onTertiary: Color(0xFF282F4D),
      // tertiaryContainer: Color(0xFF3E4565),
      // onTertiaryContainer: Color(0xFFDDE1FF),
      // error: Color(0xFFFFB4AB),
      // onError: Color(0xFF690005),
      // surface: Color(0xFF0F1416),
      // onSurface: Color(0xFFDEE3E5),
      // onSurfaceVariant: Color(0xFFBFC8CB),
      // outline: Color(0xFF899295),
    );
  }
}
