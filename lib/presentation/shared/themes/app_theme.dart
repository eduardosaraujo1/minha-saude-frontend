import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/presentation/shared/themes/dark_theme.dart';
import 'package:minha_saude_frontend/presentation/shared/themes/light_theme.dart';

class AppTheme {
  static ThemeData light() {
    return LightTheme().getTheme();
  }

  static ThemeData dark() {
    return DarkTheme().getTheme();
  }
}
