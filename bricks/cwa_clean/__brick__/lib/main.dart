import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:{{project_name}}/src/app.dart';
import 'package:{{project_name}}/src/config/app_env.dart';
{{#with_i18n}}import 'package:{{project_name}}/src/localization/translations.g.dart';{{/with_i18n}}
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
{{#backend_is_firebase}}import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:{{project_name}}/src/config/firebase/dev/firebase_options.dart' as dev;
import 'package:{{project_name}}/src/config/firebase/prod/firebase_options.dart' as prod;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:app_badge_plus/app_badge_plus.dart';{{/backend_is_firebase}}
import 'package:{{project_name}}/src/theme/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
{{#with_i18n}}  LocaleSettings.useDeviceLocale();{{/with_i18n}}
  final env = AppEnv.fromEnv();
  final logger = Logger();
  logger.i('Starting {{app_name}} in \${env.name}');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  final prefs = await SharedPreferences.getInstance();
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 300;
{{#backend_is_firebase}}  await env.map(
    dev: (_) => Firebase.initializeApp(options: dev.DefaultFirebaseOptions.currentPlatform),
    prod: (_) => Firebase.initializeApp(options: prod.DefaultFirebaseOptions.currentPlatform),
    local: (_) => Firebase.initializeApp(options: dev.DefaultFirebaseOptions.currentPlatform),
    stg: (_) => Firebase.initializeApp(options: dev.DefaultFirebaseOptions.currentPlatform),
  );
  final message = await FirebaseMessaging.instance.getInitialMessage();
  if (await AppBadgePlus.isSupported()) AppBadgePlus.updateBadge(0);
  await env.map(
    dev: (_) async => run(prefs{{#backend_is_firebase}}, message{{/backend_is_firebase}}),
    local: (_) async => run(prefs{{#backend_is_firebase}}, message{{/backend_is_firebase}}),
    stg: (_) async => run(prefs{{#backend_is_firebase}}, message{{/backend_is_firebase}}),
    prod: (vars) => SentryFlutter.init((o){ o.dsn = vars.sentryDsn; o.environment = env.name; }, appRunner: () => run(prefs{{#backend_is_firebase}}, message{{/backend_is_firebase}})),
  );
{{/backend_is_firebase}}{{^backend_is_firebase}}  run(prefs);{{/backend_is_firebase}}
}

void run(SharedPreferences prefs{{#backend_is_firebase}}, RemoteMessage? message{{/backend_is_firebase}}) => runApp(
  ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
{{#with_i18n}}    child: TranslationProvider(child: const App()),{{/with_i18n}}{{^with_i18n}}    child: const App(),{{/with_i18n}}
  ),
);
