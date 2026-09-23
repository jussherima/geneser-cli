# {{app_name}}
{{description}}

Généré avec **Geneser CWA Clean v2** — Fybego centralisé feature-first sans melos.

## Structure (lib/src)
```
lib/src/
├── app.dart + routing/app_router.dart + shared/app_error.dart
├── config/app_env.dart ({{#with_env_dev}}dev{{/with_env_dev}} {{#with_env_prod}}prod{{/with_env_prod}} {{#with_env_local}}local{{/with_env_local}})
├── features/<feature>/{data,domain,application,presentation}
│   ├── authentication (toujours)
│   ├── home (toujours)
{{#with_feed}}│   ├── feed (choisi){{/with_feed}}
{{#with_notifications}}│   ├── notifications (choisi){{/with_notifications}}
{{#with_profile}}│   ├── profile (choisi){{/with_profile}}
{{#with_language_settings}}│   └── language_settings (choisi){{/with_language_settings}}
├── theme/ + common_widgets/ + constants/ + localization/{{#with_i18n}}slang{{/with_i18n}}{{^with_i18n}}none{{/with_i18n}}
└── database/{{#with_drift}}drift{{/with_drift}}{{^with_drift}}none{{/with_drift}}
```

## Commandes
```bash
make gen             # slang + build_runner
make feature name=x  # lib/src/features/x/{data,domain,application,presentation}
flutter run --flavor dev --dart-define-from-file assets/config/dev.json
```

## Variables
project={{project_name}} flavors dev/prod/local/stg = {{#with_env_dev}}dev {{/with_env_dev}}{{#with_env_prod}}prod {{/with_env_prod}}{{#with_env_local}}local {{/with_env_local}}{{#with_env_stg}}stg{{/with_env_stg}}
