import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:{{project_name}}/src/theme/colors.dart';
import 'package:{{project_name}}/src/theme/texts.dart';
import 'package:{{project_name}}/src/theme/theme_data/theme_data.dart';
import 'package:{{project_name}}/src/theme/theme_data/theme_data_factory.dart';
part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPrefs(Ref ref) => throw UnimplementedError();

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final m = prefs.getString('theme_mode');
    return switch (m) { 'dark' => ThemeMode.dark, 'light' => ThemeMode.light, _ => ThemeMode.light };
  }
  Future<void> setMode(ThemeMode m) async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString('theme_mode', m.name);
    state = m;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: m==ThemeMode.dark?Brightness.light:Brightness.dark));
  }
}

@riverpod
ThemeData lightTheme(Ref ref) {
  final factory = const UniversalThemeFactory();
  return factory.build(colors: AppColors.light(), defaultTextStyle: AppTextTheme.build()).materialTheme;
}

@riverpod
ThemeData darkTheme(Ref ref) {
  final factory = const UniversalThemeFactory();
  return factory.build(colors: AppColors.dark(), defaultTextStyle: AppTextTheme.build()).materialTheme;
}
