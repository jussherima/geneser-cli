import 'package:flutter/material.dart';
import 'package:{{project_name}}/src/constants/app_sizes.dart';
{{#with_i18n}}import 'package:{{project_name}}/src/localization/translations.g.dart';{{/with_i18n}}
class HomeScreen extends StatelessWidget { const HomeScreen({super.key});
  @override Widget build(BuildContext c){
{{#with_i18n}}    final t = Translations.of(c);{{/with_i18n}}
    return Scaffold(appBar: AppBar(title: Text({{ #with_i18n}}t.home.title{{/with_i18n}}{{^with_i18n}}'Accueil'{{/with_i18n}})), body: Padding(padding: pageHorizontalPadding, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ sizedBoxH24, Text({{ #with_i18n}}t.home.welcome{{/with_i18n}}{{^with_i18n}}'Bienvenue 👋'{{/with_i18n}}, style: Theme.of(c).textTheme.headlineSmall), sizedBoxH12, const Text('{{app_name}} — prêt à modifier, pas à réécrire.'), sizedBoxH24, FilledButton(onPressed: (){}, child: Text({{ #with_i18n}}t.common.save{{/with_i18n}}{{^with_i18n}}'Enregistrer'{{/with_i18n}}))])));
  }
}
