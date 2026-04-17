# Contributing to Geneser

Thanks for your interest in Geneser. This guide covers the two main ways to
contribute: **adding templates and features** (the bricks that the CLI
consumes) and **improving the CLI itself**.

## Prerequisites

- Dart SDK `>= 3.3.0`
- Flutter `>= 3.22` (for testing generated projects)
- Git

## Running the CLI from source

```bash
git clone https://github.com/jussherima/geneser-cli
cd geneser-cli
dart pub get
dart run bin/geneser.dart --help
```

## Running the test suite

```bash
dart analyze
dart test
```

All tests must pass and the analyzer must be clean before opening a PR.

## Adding a new template

A template is a Mason brick that scaffolds a full Flutter project layout.

1. Create a brick directory under `bricks/<your_template_id>/`:
   ```
   bricks/<your_template_id>/
   ├── brick.yaml          # brick manifest
   ├── README.md           # describes what the template offers
   └── __brick__/          # files Mason will emit
       ├── pubspec.yaml
       ├── lib/
       │   └── main.dart
       └── ...
   ```

2. Fill `brick.yaml` with the required vars. At minimum:
   ```yaml
   name: your_template_id
   description: What the template provides.
   version: 0.1.0
   environment:
     mason: ">=0.1.0-dev.52 <0.2.0"

   vars:
     project_name:
       type: string
       default: my_app
     organization:
       type: string
       default: com.example
     description:
       type: string
       default: A new Flutter project.
   ```

3. Use Mustache variables in `__brick__/` files where substitution is needed:
   - `{{project_name}}` — package name (snake_case).
   - `{{project_name.titleCase()}}` — display name (Title Case).
   - `{{organization}}` — bundle id.
   - `{{description}}` — project description.

4. Register the template in `lib/src/models/registry.dart` under
   `Registry.builtin.templates`:
   ```dart
   Template(
     id: 'your_template_id',
     name: 'Display Name',
     description: 'One-line description.',
     author: '@your_github_handle',
     compatibleFeatures: <String>['theming_dark_light'],
   ),
   ```

5. Add a structure test under `test/bricks/your_template_id_test.dart` that
   verifies the essential files and mustache variables are present.

6. Run the full test suite: `dart analyze && dart test`.

## Adding a new feature

A feature brick adds files (and ideally does nothing else) on top of an
existing Flutter project.

1. Create `bricks/<your_feature_id>/` with the same structure as a template,
   but the `__brick__/` should contain only the feature's own files (usually
   under `lib/features/<name>/`).

2. Author a `brick.yaml` with minimal vars (often just `project_name`).

3. Add a `README.md` that documents:
   - What files are generated.
   - Any manual wiring the user needs (routes, deps, init code).
   - Any features it depends on or conflicts with.

4. Register the feature in `lib/src/models/registry.dart` under
   `Registry.builtin.features`:
   ```dart
   Feature(
     id: 'your_feature_id',
     name: 'Display Name',
     description: 'One-line description.',
     requiresIntegration: 'optional_integration_id',
     conflictsWith: <String>['another_feature_id'],
   ),
   ```

5. Add the feature id to `compatibleFeatures` for each compatible template.

6. Add a brick structure test under `test/bricks/`.

## Coding style

- Single quotes, trailing commas (`require_trailing_commas` is enforced).
- `dart format` the files under `bin/`, `lib/`, `test/` (not `bricks/`).
- Return types must be declared (`always_declare_return_types`).
- Strict casts, inference, and raw types are enabled.

## Opening a pull request

- Fork the repo, branch from `main`.
- Keep PRs focused — one template, one feature, or one fix per PR.
- Include tests for any new behavior.
- Update `CHANGELOG.md` under `[Unreleased]`.
- Open the PR with a clear description of what it does and why.

Reviewers will check: correctness, tests, code style, documentation, and
whether the change matches the project's [vision](VISION.md).

## Code of Conduct

All contributors are expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md).
