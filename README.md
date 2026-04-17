# Geneser

> Skip the Flutter boilerplate. Compose your stack, ship faster.

Geneser is an open-source CLI that bootstraps and extends Flutter projects by
composing curated templates and features. Skip `flutter create` + 3 days of
wiring and jump straight to writing real code.

## Why Geneser

Every Flutter project starts with the same setup: routing, state management,
theming, folder layout, tests. Geneser removes that friction.

Unlike `very_good_cli`, Geneser is not opinionated on a single architecture —
you pick the template that fits, and compose features on top.

## Install

```bash
dart pub global activate geneser
```

> Not yet published on pub.dev. For now, run from source:
>
> ```bash
> git clone https://github.com/jussherima/geneser-cli
> cd geneser-cli
> dart pub get
> dart run bin/geneser.dart --help
> ```

## Quick start

### Interactive mode (default)

```bash
geneser create
```

You'll be prompted for the project name, organization, architecture template,
and optional features.

### Non-interactive mode (scripts, CI)

```bash
geneser create \
  --name my_app \
  --organization com.example \
  --template starter_riverpod_gorouter \
  --feature theming_dark_light \
  --feature auth_firebase \
  --yes
```

### Browse available templates and features

```bash
geneser list
```

### Add a feature to an existing Geneser project

```bash
cd my_app
geneser add
```

Geneser reads the project's `.geneser.yaml` manifest, shows compatible features
that aren't installed yet, and applies the ones you select.

### Inspect your environment

```bash
geneser doctor
```

Verifies Dart, Flutter, Git are available. Run inside a generated project for
additional project context.

## Commands

| Command | Purpose |
|---|---|
| `geneser create` | Create a new Flutter project from a template |
| `geneser add` | Add features to an existing Geneser project |
| `geneser list` | Browse available templates and features |
| `geneser doctor` | Diagnose your local environment and project |

Run `geneser help <command>` for detailed options.

## What's in the box

### Templates

- **`starter_riverpod_gorouter`** — Riverpod for state, go_router for
  navigation, Material 3 with light/dark theme, two example screens. A
  pragmatic starting point.

### Features

- **`theming_dark_light`** — Settings screen with system/light/dark toggle,
  Riverpod-backed theme mode.
- **`auth_firebase`** — Auth layer (repository + provider + login screen) with
  an in-memory stub implementation. Swap for Firebase when ready.

## Philosophy

- **Composition over configuration.** Pick an architecture, pick your
  integrations, pick your features. Geneser wires them together.
- **Autonomy.** The generated project has zero runtime dependency on Geneser.
  Once created, it stands on its own.
- **Community-driven.** Templates come from identified contributors, not a
  single company. Submit yours via pull request.

## Requirements

- Dart SDK `>= 3.3.0`
- Flutter `>= 3.22` (for generated projects)
- Git (optional but recommended)

## Contributing

Pull requests are welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to
add templates and features. All contributors are expected to follow the
[code of conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE)
