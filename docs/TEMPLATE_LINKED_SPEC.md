# Linked Template Spec — Geneser v0.2

> Entrée unique : un **dossier template à linker** (`--from <path|url>`), pas un catalogue hardcodé.
> Le template contient : les champs à demander, la structure de dossiers, le contenu des fichiers.
> Post-v1 : même format, mais exposé via marketplace (`geneser create` sans `--from` → recherche + score).

## 1. Principe

```
Link template ──► Questionnaire auto-généré ──► Projet Flutter généré

brick.yaml (vars) ──► prompts
__brick__/         ──► structure + contenus (Mustache)
```

- **v0.1** : `Registry.builtin` + `bricks/<id>/` locaux (hardcodé).
- **v0.2** : `geneser create --from <path|git-url>` → fetch brick → prompts → génération.
- **v1** : marketplace distante (même bricks, listés avec scores).

### Architecture découplée

- **Moteur Dart (`geneser-cli`)** : interpréteur du template. Aucune architecture en dur. Rôle : parser `brick.yaml`, générer le questionnaire, orchestrer les commandes, puis appliquer `__brick__/`.
- **Template Brick** : contient tout — questionnaires (`vars`), architecture de dossiers (`__brick__/`), contenu de chaque fichier (`{{vars}}` + conditionnels).

> Plus de dépendance à l'archi locale : le moteur ne fige rien, chaque template apporte sa propre archi.

**NB — Commandes dans le template :** un template peut utiliser des commandes pour générer un projet de base (ex. `flutter create . --project-name {{project_name}}`). Le moteur **attend** que la commande termine et que le projet de base soit bien généré avant de générer les dossiers nécessaires. Implémentation : `lib/src/services/generator_service.dart:88-94` (`await _runFlutterCreate(request)` puis `await _applyBrick(request, targetDir)` ; `Process.run` bloquant, `fileConflictResolution: overwrite`).

## 2. Structure d'un template lié

```
my-template/
├── brick.yaml              # obligatoire : métadonnées + questionnaire
├── README.md               # optionnel : décrit le template
└── __brick__/              # obligatoire : fichiers à générer
    ├── pubspec.yaml        # avec {{project_name}}, {{description}}
    ├── lib/
    │   ├── main.dart
    │   └── features/
    └── test/
```

### brick.yaml — les champs à demander

```yaml
name: clean_arch
description: Clean Architecture + Riverpod
version: 0.1.0
environment:
  mason: ">=0.1.0-dev.52 <0.2.0"

vars:
  project_name:
    type: string
    description: Nom du projet en snake_case
    prompt: Nom du projet ?
    default: my_app
  organization:
    type: string
    description: Bundle ID reverse-DNS
    default: com.example
    prompt: Organization ?
  description:
    type: string
    default: A new Flutter project
  use_firebase:
    type: boolean
    default: false
    prompt: Utiliser Firebase ?
  auth_provider:
    type: enumeration
    values: [firebase, supabase, none]
    default: none
```

Types supportés (Mason) : `string`, `boolean`, `number`, `enumeration`, `array`.

Le CLI génère le questionnaire depuis `vars` (via `mason_logger` : `prompt`, `confirm`, `chooseOne`, `chooseAny`).

### __brick__/ — structure + contenu

Tout ce qui est sous `__brick__/` est copié tel quel dans le projet cible, avec substitution Mustache :

- `{{project_name}}` → nom snake_case
- `{{project_name.titleCase()}}`, `{{project_name.pascalCase()}}` → variantes
- `{{organization}}`, `{{description}}`
- `{{#use_firebase}}...{{/use_firebase}}` → sections conditionnelles
- `{{#auth_provider.firebase}}...{{/auth_provider.firebase}}`

Exemple `__brick__/pubspec.yaml` :
```yaml
name: {{project_name}}
description: "{{description}}"
dependencies:
  flutter:
    sdk: flutter
  {{#use_firebase}}firebase_core: ^2.0.0{{/use_firebase}}
```

Exemple `__brick__/lib/main.dart` :
```dart
import 'package:{{project_name}}/app/app.dart';
```

## 3. Génération (orchestrée par le moteur, définie par le brick)

1. `flutter create . --project-name {{project_name}} --org {{organization}}` (scaffolding plateforme) — commande déclarable par le template, **le moteur attend la fin** (`await Process.run`, `lib/src/services/generator_service.dart:101-123`).
2. `MasonGenerator.fromBrick(Brick.path|git(url)).generate(target, vars)` → overlay `__brick__/` avec `FileConflictResolution.overwrite` — **structure + contenus du brick** (`lib/src/services/generator_service.dart:126-143`).
3. Écriture `.geneser.yaml` (trace `template.id`, `project`, `features`)
4. `flutter pub get` + `git init` + commit initial

> Le brick peut déclarer d'autres commandes pré-génération (ex. `very_good create`, `melos bootstrap`) ; le moteur les exécute séquentiellement et n'applique `__brick__/` qu'une fois la base prête.

Référence : `lib/src/services/generator_service.dart:54-99` et `resolveBrickPath` (`GENESER_BRICKS_DIR` > walk-up `Platform.script` > `./bricks/<id>`).

## 4. Usage

```bash
# Local
geneser create --from ./templates/clean_arch
geneser create --from ./templates/clean_arch --name my_app --organization com.example --yes

# Distant (git)
geneser create --from https://github.com/user/flutter-starter.git
geneser create --from https://github.com/user/flutter-starter.git --name my_app --yes

# Binaire compilé (nécessite le dossier bricks)
GENESER_BRICKS_DIR=/path/to/bricks geneser create --from ./my-template --name my_app --yes
# ou bricks à côté du binaire : ./bricks/my-template/
```

## 5. Marketplace (post-v1)

Même format de brick, mais indexé :

```yaml
# registry.yaml distant
templates:
  - id: clean_arch
    name: Clean Architecture
    description: ...
    author: "@user"
    score: 4.8
    downloads: 1200
    source: https://github.com/user/clean_arch_brick.git
    compatible_features: [auth_firebase]
```

```bash
geneser create              # affiche marketplace : top scores
geneser list                # idem
geneser search clean        # filtre
geneser create --template clean_arch --name my_app --yes  # depuis marketplace
```

Tri : score, downloads, compatibilité.

## 6. Migration depuis v0.1

- `bricks/starter_riverpod_gorouter/` devient le premier template lié de référence.
- `lib/src/models/registry.dart:25` `Registry.builtin` reste en fallback si pas de `--from` et pas de registre distant.
- `CONTRIBUTING.md` : créer un template = créer un dossier `bricks/<id>/` avec `brick.yaml` + `__brick__/` (inchangé).

## 7. Références

- `bricks/starter_riverpod_gorouter/brick.yaml` — exemple complet
- `lib/src/services/generator_service.dart:130` — overlay Mason
- `lib/src/commands/create_command.dart:35` — cible pour l'option `--from`
- `VISION.md:6` + `CDC.md` — vision produit
