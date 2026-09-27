// ≈ res/values/colors.xml + themes.xml + styles.xml, but written in Dart.
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color seed = Color(0xFF0B6BCB); // ≈ colorPrimary

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(centerTitle: false),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: Brightness.dark,
  );
}
