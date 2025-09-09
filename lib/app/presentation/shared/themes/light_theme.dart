import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/presentation/shared/themes/theme_variant.dart';

class LightTheme implements ThemeVariant {
  static const seedColor = Color(0xFF003039);

  @override
  ThemeData getTheme() {
    final scheme = colorScheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceBright,
    );
  }

  @override
  ColorScheme colorScheme() {
    final seededScheme = ColorScheme.fromSeed(seedColor: LightTheme.seedColor);

    return seededScheme.copyWith(
      // primary: Color(0xFF006879),
      // onPrimary: Color(0xFFFFFFFF),
      // primaryContainer: Color(0xFFA9EDFF),
      // onPrimaryContainer: Color(0xFF004E5C),
      // secondary: Color(0xFF4B6268),
      // onSecondary: Color(0xFFFFFFFF),
      // secondaryContainer: Color(0xFFCEE7EE),
      // onSecondaryContainer: Color(0xFF334A50),
      // tertiary: Color(0xFF565D7E),
      // onTertiary: Color(0xFFFFFFFF),
      // tertiaryContainer: Color(0xFFDDE1FF),
      // onTertiaryContainer: Color(0xFF3E4565),
      // error: Color(0xFFBA1A1A),
      // onError: Color(0xFFFFFFFF),
      // surface: Color(0xFFF5FAFC),
      // onSurface: Color(0xFF171C1E),
      // onSurfaceVariant: Color(0xFF3F484B),
      // outline: Color(0xFF70797B),
    );
  }
}
