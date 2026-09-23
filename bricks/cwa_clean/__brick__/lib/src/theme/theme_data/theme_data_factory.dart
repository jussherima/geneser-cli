import 'package:{{project_name}}/src/theme/colors.dart'; import 'package:{{project_name}}/src/theme/texts.dart'; import 'package:{{project_name}}/src/theme/theme_data/theme_data.dart';
abstract class AppThemeDataFactory { AppThemeData build({required AppColors colors, required AppTextTheme defaultTextStyle}); }
