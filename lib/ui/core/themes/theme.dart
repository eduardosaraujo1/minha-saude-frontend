import 'package:flutter/material.dart';
import 'color_schemes.dart';

/// Defines the app's theme configuration.
/// This class is responsible for providing the complete theme configuration
/// including color schemes, text themes, and other theme data.
class AppTheme {
  /// Gets the complete light theme configuration
  static ThemeData get light => ThemeData(
    colorScheme: AppColorSchemes.light,
    textTheme: TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.w500),
      titleLarge: TextStyle(fontWeight: FontWeight.w500),
    ),
    scaffoldBackgroundColor: AppColorSchemes.light.surfaceBright,
    useMaterial3: true,
    // Add more theme configurations here:
    // textTheme: AppTextTheme.light,
    // cardTheme: AppCardTheme.light,
    // appBarTheme: AppBarTheme.light,
    // etc.
  );

  /// Gets the complete dark theme configuration
  static ThemeData get dark => ThemeData(
    colorScheme: AppColorSchemes.dark,
    scaffoldBackgroundColor: AppColorSchemes.dark.surfaceBright,
    useMaterial3: true,
    // Add more theme configurations here:
    // textTheme: AppTextTheme.dark,
    // cardTheme: AppCardTheme.dark,
    // appBarTheme: AppBarTheme.dark,
    // etc.
  );
}
