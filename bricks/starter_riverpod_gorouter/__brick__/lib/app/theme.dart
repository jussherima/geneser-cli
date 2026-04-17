import 'package:flutter/material.dart';

ThemeData appTheme(Brightness brightness) {
  return ThemeData(
    brightness: brightness,
    colorSchemeSeed: Colors.indigo,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
