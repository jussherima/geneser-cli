import 'package:flutter/material.dart'; import 'package:flutter_riverpod/flutter_riverpod.dart'; import 'package:flutter_test/flutter_test.dart';
{{#with_i18n}}import 'package:{{project_name}}/src/localization/translations.g.dart';{{/with_i18n}}
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget w, {List<Override> overrides=const []}) async {
{{#with_i18n}}    await pumpWidget(TranslationProvider(child: ProviderScope(overrides: overrides, child: MaterialApp(home: w))));{{/with_i18n}}{{^with_i18n}}    await pumpWidget(ProviderScope(overrides: overrides, child: MaterialApp(home: w)));{{/with_i18n}}
  }
}
