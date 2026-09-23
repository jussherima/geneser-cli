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

## How it works — linked template (v0.2 target)

> **Current v0.1:** templates are hardcoded (`starter_riverpod_gorouter`). **Target v0.2:** you link a template folder (local path or git URL). The template already contains the fields to ask + the file/folder structure to generate.

```
Link template → Auto questionnaire from brick.yaml vars → Flutter boilerplate (structure + file contents)
```

**Architecture — no longer coupled to local arch:**

- **Dart Engine (`geneser-cli`)** — template interpreter. Knows no architecture; it orchestrates and waits for commands to finish before generating folders/files.
- **Template Brick** — owns everything: questionnaires (`brick.yaml` vars) + folder architecture (`__brick__/`) + content of each file to generate (Mustache `{{vars}}`).

> **NB:** A template may declare base commands (e.g. `flutter create`). The engine waits until each command completes and the base project is generated, then it generates the required folders/files (`lib/src/services/generator_service.dart:88-94`).

A template is a Mason brick:

```
my-template/
├── brick.yaml      # vars = fields to ask (questionnaire)
└── __brick__/      # folder structure + file contents (Mustache {{vars}})
```

Post-v1: `geneser create` without `--from` will show a marketplace (search, top scores). For now the entry point is a single linked template.

## Quick start

### Interactive mode — linked template (v0.2)

```bash
geneser create --from ./my-template
# or
geneser create --from https://github.com/user/flutter-starter.git
```

You'll be prompted for every `vars` defined in `brick.yaml` (e.g. `project_name`, `organization`, `description`), then the project is generated with the exact structure + contents from `__brick__/`.

### Interactive mode — builtin template (v0.1, backwards compatible)

```bash
geneser create
```

You'll be prompted for the project name, organization, architecture template,
and optional features.

### Non-interactive mode (scripts, CI)

```bash
# Linked template
geneser create --from ./my-template --name my_app --organization com.example --yes

# Builtin template (v0.1)
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
# v0.2: lists builtin + linked registry; v1: marketplace with scores & search
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
| `geneser create --from <path\|url>` | Create a new Flutter project from a linked template (v0.2) |
| `geneser create --template <id>` | Create from a builtin template (v0.1, backwards compat) |
| `geneser add` | Add features to an existing Geneser project |
| `geneser list` | Browse available templates and features (marketplace post-v1) |
| `geneser doctor` | Diagnose your local environment and project |

Run `geneser help <command>` for detailed options.

## What's in the box

### Linked template format (v0.2)

Every template is a folder you link:

```
my-template/
├── brick.yaml   # vars → questionnaire fields (project_name, organization, ...)
└── __brick__/   # structure + file contents → generated as-is with {{vars}}
```

See `bricks/starter_riverpod_gorouter/` as the reference template and `docs/TEMPLATE_LINKED_SPEC.md` for the full spec.

### Builtin Templates (v0.1)

- **`starter_riverpod_gorouter`** — Riverpod for state, go_router for
  navigation, Material 3 with light/dark theme, two example screens. A
  pragmatic starting point. Will become the first linked template reference.

### Features

- **`theming_dark_light`** — Settings screen with system/light/dark toggle,
  Riverpod-backed theme mode.
- **`auth_firebase`** — Auth layer (repository + provider + login screen) with
  an in-memory stub implementation. Swap for Firebase when ready.

## Philosophy

- **One template in, one project out.** Link a template folder → answer the questionnaire → get a Flutter project with the exact structure + file contents defined in the template.
- **Composition over configuration.** Pick an architecture, pick your
  integrations, pick your features. Geneser wires them together.
- **Autonomy.** The generated project has zero runtime dependency on Geneser.
  Once created, it stands on its own.
- **Marketplace later, linked folder now.** Post-v1: browse/search/score on `geneser create`. Now: `geneser create --from <path|url>`.
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
