import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:{{project_name}}/src/common_widgets/app_error.dart';
import 'package:{{project_name}}/src/theme/providers/theme_provider.dart';
import 'package:{{project_name}}/src/routing/app_router.dart';
{{#with_i18n}}import 'package:{{project_name}}/src/localization/translations.g.dart';{{/with_i18n}}
import 'package:toastification/toastification.dart';

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ErrorWidget.builder = (d) => AppErrorWidget(error: d);
    final router = ref.watch(appRouterProvider);
    final mode = ref.watch(themeModeNotifierProvider);
    final light = ref.watch(lightThemeProvider);
    final dark = ref.watch(darkThemeProvider);
    return ToastificationWrapper(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: "{{app_name}}",
        theme: light,
        darkTheme: dark,
        themeMode: mode,
        routerConfig: router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FormBuilderLocalizations.delegate,
        ],
{{#with_i18n}}        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,{{/with_i18n}}{{^with_i18n}}        supportedLocales: const [Locale('fr'), Locale('en')],{{/with_i18n}}
      ),
    );
  }
}
