# CWA Clean — Boilerplate Prêt à Modifier

> **CWA = Clean + Centralisé + Prêt à l'emploi.** Basé sur l'invariant `Fybego` (monorepo 374 fichiers, `melos.yaml:3`) + `AgenceBrioche` (mono-repo 250 fichiers, `lib/environnements.dart:27`).

## Générer un projet

```bash
geneser create --from ./bricks/cwa_clean --name kandra --organization net.forgero --yes
# ou
geneser create --template cwa_clean --name kandra --organization net.forgero --yes
# avec vars Mason direct:
mason make cwa_clean --project_name kandra --app_name Kandra --organization net.forgero --backend_url https://api.kandra.mg --primary_color "0xFF0E7A4B" --with_drift true --with_firebase false
```

## Variables

| Variable | Défaut | Impact |
|---|---|---|
| `project_name` | `biznaka_app` | `pubspec.yaml:1`, `lib/main.dart` |
| `app_name` | `BizNaka` | `lib/app.dart:65` title, `README` |
| `organization` | `com.example` | `android/app/build.gradle.kts:1` |
| `bundle_id` | `""` (auto) | `android/ios`, `firebase.json` |
| `primary_color` | `0xFF0E7A4B` | `lib/core/theme/colors.dart:1` |
| `backend_url` | `https://api.example.com` | `lib/environnements.dart:11` |
| `with_drift` | `true` | `lib/core/database/` (Drift) |
| `with_firebase` | `false` | `lib/firebase/{dev,prod}` |
| `flavors` | `dev,prod` | `.vscode/launch.json`, `Assets.xcassets` |

## Structure générée (90 fichiers)

```
lib/
├── main.dart, app.dart, environnements.dart, router.dart, routes.dart, app_error.dart
├── core/{theme,data,guards,initializer,states,persistence,database,services,utils,widgets}
├── modules/authenticated/{home,expenses,profile,ui}
├── modules/not_authenticated/authentication/
└── i18n/strings.i18n.json
```

## Règle [MOD] 0/1

- `[MOD] 0` : 0 ligne — `analysis_options.yaml` strict, `Makefile`, `slang.yaml`, `onstart_widget`
- `[MOD] 1 champ/hex` : `colors.dart` 1 hex, `environnements.dart` 1 URL, `routes.dart` 1 `TypedGoRoute`

## Gain

Sans: 12-18j copier-coller. Avec: `make feature name=credits` → feature verticale complète `api→providers→repositories→ui`.

## Sources

- `AgenceBrioche:app-mobile/lib/core/theme/colors.dart:1`, `universal_theme.dart:1`, `http_client.dart:1`, `Makefile:1`, `slang.yaml:1`
- `Fybego:fybego-standard-app/apps/fybego/lib/src/exceptions/app_exception.dart:1`, `packages/theme/lib/src/theme/data/theme_colors_data.dart:1`
