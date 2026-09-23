import 'package:flutter/material.dart'; import 'package:{{project_name}}/src/theme/colors.dart'; import 'package:{{project_name}}/src/theme/texts.dart';
class AppThemeData { final AppColors colors; final AppTextTheme defaultTextTheme; final ThemeData materialTheme; const AppThemeData({required this.colors, required this.defaultTextTheme, required this.materialTheme}); }
class AppThemeUniform extends AppThemeData { AppThemeUniform(AppThemeData d): super(colors: d.colors, defaultTextTheme: d.defaultTextTheme, materialTheme: d.materialTheme); }
