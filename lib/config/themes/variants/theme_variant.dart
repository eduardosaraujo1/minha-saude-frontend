import 'package:flutter/material.dart';

abstract class ThemeVariant {
  ThemeData getTheme();
  ColorScheme colorScheme();
}
