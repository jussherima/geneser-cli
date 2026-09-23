# TASKS — v0.2.0 Template Lié

> But : passer de v0.1 hardcodé → v0.2 **un dossier template à linker** (`--from <path|url>`).
> Architecture : **Moteur Dart (`geneser-cli`) = interpréteur** / **Template Brick = questionnaires + archi dossiers + contenu fichiers**.
> Référence : `docs/TEMPLATE_LINKED_SPEC.md`, `VISION.md:6`, `CDC.md`.

Chaque tâche est autonome pour une session `opencode`. Cocher `[x]` une fois `dart analyze && dart test` verts.

---

## Phase 1 — Spec (fait, à lire avant de coder)

### T1 — Lire la spec
- **Fichiers** : `docs/TEMPLATE_LINKED_SPEC.md`, `VISION.md`, `CDC.md`, `README.md`, `bricks/starter_riverpod_gorouter/brick.yaml`
- **Attente** : comprendre que `brick.yaml` `vars` = questionnaire auto, `__brick__/` = structure + Mustache, moteur attend `flutter create` avant overlay.
- **Critère** : capable d'expliquer le flux `link --from → prompts → flutter create → overlay → pub get → git init`.

---

## Phase 2 — Moteur Dart (`lib/src/services/generator_service.dart`)

### T2 — Fix `resolveBrickPath` pour binaire compilé
- **Fichier** : `lib/src/services/generator_service.dart:209-226`
- **Problème** : `dart compile exe -o /tmp/geneser-dart` → `Platform.script=/tmp/geneser-dart` → walk-up `/tmp/bricks` + fallback `cwd/bricks` → `Brick not found at ".../test_environnement/bricks/..."` (vu en live).
- **Attentes** :
  1. Garder ordre : `GENESER_BRICKS_DIR` > walk-up `Platform.script` > walk-up `Platform.resolvedExecutable` (nouveau) > `./bricks/<id>`.
  2. Walk-up `resolvedExecutable` sur 6 niveaux comme pour `script`.
  3. Si non trouvé, erreur claire : `Brick "X" not found. Tried: ... . Hint: set GENESER_BRICKS_DIR or place bricks next to binary.`
- **Tests** : ajouter `test/services/generator_service_test.dart` cas `compiled exe without bricks` et `GENESER_BRICKS_DIR override`.
- **Vérif** : `dart compile exe bin/geneser.dart -o /tmp/geneser-dart && /tmp/geneser-dart create --help` + `GENESER_BRICKS_DIR=bricks /tmp/geneser-dart create --from ./bricks/starter_riverpod_gorouter --name x --organization com.example --yes` passe.

### T3 — Généraliser `GenerationRequest` pour vars arbitraires
- **Fichier** : `lib/src/services/generator_service.dart:16-34`
- **Actuel** : `projectName`, `organization`, `description` en dur.
- **Attentes** :
  1. Remplacer par `final Map<String,dynamic> vars` + getters helpers `projectName => vars['project_name']`.
  2. Rétrocompat : `GenerationRequest(projectName: "my_app", ...)` doit encore compiler via factory ou constructeur nommé.
  3. `_applyBrick` passe `vars` tel quel à `MasonGenerator.generate(vars: request.vars)`.
  4. `_writeManifest` écrit `projectName`/`organization` depuis `vars`.
- **Tests** : `generator_service_test.dart` avec `vars: {"project_name":"a","custom_field":"v"}`.

### T4 — Support `Brick.git(url)` en plus de `Brick.path`
- **Fichier** : `lib/src/services/generator_service.dart:126-143`
- **Actuel** : `Brick.path(request.brickPath)` uniquement.
- **Attentes** :
  1. Si `brickPath` commence par `https://` ou `git@` → `Brick.git(GitPath(...))` sinon `Brick.path`.
  2. Gérer `MasonGenerator.fromBrick` pour les deux cas, même `fileConflictResolution: overwrite`.
  3. Cache Mason : si git, clonage temporaire géré par Mason, pas de left-over.
- **Tests** : mock test avec `brickPath: "https://github.com/user/brick.git"` (vérifier que `Brick.git` est appelé, pas besoin de vrai réseau — mocker `MasonGenerator`).
- **Vérif manuelle** : `geneser create --from https://github.com/mason-registry/brick_example.git --name my_app --yes` (si réseau).

### T5 — Séquence bloquante explicite (doc + code)
- **Fichier** : `lib/src/services/generator_service.dart:88-94`
- **Attentes** :
  1. Commenter que le moteur **attend** `await _runFlutterCreate` avant `await _applyBrick` (déjà le cas, mais à documenter).
  2. Si `brick.yaml` déclare `pre_gen_command` (optionnel futur), l'exécuter séquentiellement avant `_applyBrick`. Pour v0.2, juste prévoir le hook (pas obligatoire d'implémenter, mais laisser `TODO`).
  3. Pas de génération `__brick__/` si `flutter create` a échoué (throw).

---

## Phase 3 — CLI (`lib/src/commands/create_command.dart`)

### T6 — Ajouter option `--from`
- **Fichier** : `lib/src/commands/create_command.dart:23-54`
- **Attentes** :
  1. `argParser.addOption('from', help: 'Chemin local ou URL git du brick à linker (ex: ./my-template ou https://github.com/user/brick.git).')`
  2. `help` décrit que `--from` est exclusif avec `--template`.
  3. `lib/geneser.dart` help global reste inchangé.
- **Tests** : `create_command_test.dart` vérifie que `--from` est parsé.

### T7 — Logique `--from` vs `--template` (bypass registry)
- **Fichier** : `lib/src/commands/create_command.dart:68-100`, `lib/src/commands/create_command.dart:221-239`
- **Attentes** :
  1. Si `argResults['from'] != null` :
     - Ne pas appeler `registry.templateById`.
     - Vérifier que le path/url existe (local : `Directory(path).existsSync()` ou contient `brick.yaml`, distant : validation URL).
     - Si `--template` aussi présent → `throw UsageException('--from and --template are mutually exclusive')`.
     - Résoudre `brickPath = argResults['from']`.
  2. Sinon : comportement v0.1 inchangé (`_resolveTemplate`).
  3. `selectedTemplate` peut être `null` en mode `--from` ; adapter `_printSummary` et `GenerationRequest.templateId` (utiliser `p.basename(brickPath)` ou `brick.yaml` `name`).
- **Tests** : `rejects --from with --template together`, `resolves --from local path`, `rejects invalid --from path`.

### T8 — Questionnaire auto depuis `brick.yaml` vars
- **Fichier** : `lib/src/commands/create_command.dart:242-281` (`_resolveFeatures` et nouveau `_resolveBrickVars`)
- **Actuel** : prompts hardcodés pour `project_name`/`organization`.
- **Attentes** :
  1. Créer `BrickYamlService` ou helper `parseBrickYaml(String brickPath) → Map<String, BrickVar>` lisant `brick.yaml` `vars` (type, prompt, default, values).
  2. Nouveau `_resolveVars(String brickPath)` : pour chaque var dans `brick.yaml`, si `argResults[varName] != null` → utiliser, sinon si `--yes` → default, sinon `logger.prompt/confirm/chooseOne` selon `type`.
  3. Support `string` → `prompt`, `boolean` → `confirm`, `enumeration` → `chooseOne`.
  4. Valider `project_name` avec `Validators.packageName` si présent dans vars.
  5. Retourner `Map<String,dynamic> vars` passé à `GeneratorService`.
- **Tests** : `brick_yaml_parsing_test.dart` (vars string/bool/enum) + `create_command_test.dart` avec `--from` et `brick.yaml` temporaire.
- **Vérif manuelle** : `geneser create --from ./bricks/starter_riverpod_gorouter` → prompts pour `project_name`, `organization`, `description`.

### T9 — Mode non-interactif pour `--from`
- **Fichier** : `lib/src/commands/create_command.dart:68-131`
- **Attentes** :
  1. Si `--yes` et vars non fournies → utiliser `default` de `brick.yaml`.
  2. Si var sans default et non fournie + `--yes` → `throw UsageException('Missing required var: X')`.
  3. Permettre de passer vars arbitraires en CLI : `geneser create --from ./tpl --name my_app` doit mapper `--name` → `project_name` (rétrocompat) + support générique `--var-<name>=value` ou au moins documenter que `project_name`/`organization`/`description` restent les flags principaux.
  4. Ne pas demander `organization` si déjà dans `vars` et fourni.
- **Tests** : `non-interactive --from with --yes uses defaults`, `missing required var throws`.

---

## Phase 4 — Brick lié de référence

### T10 — Créer brick lié de test
- **Fichiers** : `bricks/clean_arch_linked/` (copie minimale de `starter_riverpod_gorouter` avec `brick.yaml` renommé)
- **Attentes** :
  1. `brick.yaml` `name: clean_arch_linked` + même `vars` que starter.
  2. `__brick__/` avec `pubspec.yaml` `name: {{project_name}}` + structure `lib/features/`.
  3. Pas d'enregistrement dans `Registry.builtin` (test du mode lié, pas hardcodé).
- **Vérif** : `dart run bin/geneser.dart create --from ./bricks/clean_arch_linked --name test_linked --organization com.example --yes` → `flutter analyze` pass.

---

## Phase 5 — Tests & Qualité

### T11 — Tests unitaires
- **Fichiers** : `test/services/generator_service_test.dart`, `test/commands/create_command_test.dart`, nouveau `test/services/brick_yaml_service_test.dart`
- **Attentes** : couvrir T2-T9, mocker `Process.run` pour ne pas appeler vrai `flutter create` en CI.
- **Critère** : `dart test` 100% pass en <20s.

### T12 — Tests d'intégration Mason
- **Fichier** : `test/services/mason_integration_test.dart`
- **Attentes** : générer un vrai projet dans `Directory.systemTemp` avec `--from` local et vérifier `pubspec.yaml` contient `{{project_name}}` substitué, `lib/main.dart` existe.

### T13 — Analyse
- **Critère** : `dart analyze` 0 issue.

---

## Phase 6 — Docs & Release

### T14 — Contribuer
- **Fichier** : `CONTRIBUTING.md`
- **Attentes** : ajouter section `## Creating a linked template` avec exemple `brick.yaml` + `__brick__/` + commande `geneser create --from ...`.

### T15 — Changelog & Version
- **Fichiers** : `CHANGELOG.md`, `pubspec.yaml`
- **Attentes** : ajouter `[0.2.0] - Linked template` avec liste des changements, bump `version: 0.2.0`.

---

## Ordre conseillé pour sessions parallèles

- Session A : T2 + T3 (moteur, indépendant)
- Session B : T6 + T7 (CLI, dépend de A pour `GenerationRequest`)
- Session C : T8 + T9 (questionnaire, dépend de B)
- Session D : T4 + T10 (git brick + brick ref, indépendant)
- Session E : T11-T13 (tests, après A-D)

## Vérification finale (à faire par chaque session)

```bash
dart analyze
dart test
dart run bin/geneser.dart --help
dart run bin/geneser.dart create --from ./bricks/starter_riverpod_gorouter --name my_app --organization com.example --yes
cd my_app && flutter analyze && flutter test && cat .geneser.yaml
```

