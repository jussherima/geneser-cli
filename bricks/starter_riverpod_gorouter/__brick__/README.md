# {{project_name.titleCase()}}

{{description}}

Generated with [Geneser](https://github.com/jussherima/geneser-cli) using the
`starter_riverpod_gorouter` template.

## Getting started

```bash
flutter pub get
flutter run
```

## Project structure

```
lib/
├── main.dart            # entry point with ProviderScope
├── app/
│   ├── app.dart         # MaterialApp.router
│   ├── router.dart      # go_router configuration
│   └── theme.dart       # light/dark theme
└── features/
    ├── home/            # home screen
    └── about/           # about screen
```

## Architecture

- **State management** — [Riverpod](https://riverpod.dev/)
- **Routing** — [go_router](https://pub.dev/packages/go_router)
- **Theme** — Material 3 with light/dark support

## What to do next

1. Add your first real feature under `lib/features/<name>/`.
2. Register its route in `lib/app/router.dart`.
3. If it needs state, expose a provider and consume it with `ConsumerWidget`.
