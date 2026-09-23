# Architecture CWA v2 — {{app_name}} (Fybego sans melos)

> Feature-first, Clean, Centralisé (1 pubspec)

**Flux** `presentation → application → domain ← data (Dio/Drift)`

**Fybego ref** `apps/fybego/lib/src/features/authentication/{application,data,domain,presentation}`

**Choix visibles**:
- Env: {{#with_env_dev}}dev {{/with_env_dev}}{{#with_env_prod}}prod {{/with_env_prod}}{{#with_env_local}}local {{/with_env_local}}{{#with_env_stg}}stg{{/with_env_stg}}
- Features: {{#with_feed}}feed {{/with_feed}}{{#with_notifications}}notifications {{/with_notifications}}{{#with_profile}}profile {{/with_profile}}{{#with_language_settings}}language_settings{{/with_language_settings}}
- i18n: {{#with_i18n}}slang{{/with_i18n}}{{^with_i18n}}none{{/with_i18n}}

**Shared**: `lib/src/shared/app_error.dart`, `lib/src/routing/*`, `lib/src/constants/app_sizes.dart`

**Ajouter 1 feature**: `make feature name=credits` → 4 dossiers + `make gen`
