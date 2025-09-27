import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/ui/core/themes/variants/dark_theme.dart';
import 'package:minha_saude_frontend/app/ui/core/themes/variants/light_theme.dart';

class AppTheme extends ChangeNotifier {
  late ThemeData _selectedTheme;

  ThemeData get selectedTheme => _selectedTheme;

  AppTheme() {
    _selectedTheme = _light();
  }

  void selectLightTheme() {
    _selectedTheme = _light();
    notifyListeners();
  }

  void selectDarkTheme() {
    _selectedTheme = _dark();
    notifyListeners();
  }

  void selectCustomTheme(ThemeData theme) {
    _selectedTheme = theme;
    notifyListeners();
  }

  ThemeData _light() {
    return LightTheme().getTheme();
  }

  ThemeData _dark() {
    return DarkTheme().getTheme();
  }
}
