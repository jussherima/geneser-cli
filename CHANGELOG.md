# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### CLI
- Initial project scaffold with Dart CLI entry point, lints, CI workflow.
- Four commands: `create`, `add`, `list`, `doctor`.
- `--version` and `--help` flags at top level and per command.
- Non-interactive mode for `create`: `--name`, `--template`, `--organization`,
  `--feature` (repeatable), `--yes`.
- `--refresh` flag on `create` and `list` to bypass the registry cache.
- `geneser doctor` reports current project context when run inside a Geneser
  project (name, template, installed features).

#### Registry
- `RegistryService` with remote fetch + local cache (1h TTL) + fallback to a
  built-in registry.
- YAML-based registry schema (templates + features + integrations).
- Conflict detection between features.

#### Generation
- `GeneratorService` orchestrates: `flutter create` → Mason overlay →
  `.geneser.yaml` manifest → `flutter pub get` → `git init`.
- First template: `starter_riverpod_gorouter` (Riverpod + go_router + Material 3).
- `.geneser.yaml` manifest tracks template + installed features.

#### Features
- First feature: `theming_dark_light` (settings screen with theme toggle).
- Second feature: `auth_firebase` (auth layer with in-memory stub;
  instructions for Firebase integration).
- `geneser add` applies feature bricks on top of an existing project and
  updates the manifest.

#### Testing
- 40+ tests covering validators, registry parsing, generator failure modes,
  manifest round-trip, feature application, brick structure, and Mason
  integration end-to-end.
