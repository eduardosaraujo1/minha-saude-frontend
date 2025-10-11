import 'package:flutter/material.dart';

ThemeData applyOverrides(ThemeData themeData) {
  final colorScheme = themeData.colorScheme;

  return themeData.copyWith(
    scaffoldBackgroundColor: colorScheme.surfaceBright,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(), //
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      actionTextColor: colorScheme.inversePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surfaceContainer, //
    ),
  );
}
