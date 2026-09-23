# BUT

- Générer un projet Flutter à partir d'un **template lié** (dossier local ou distant) qui décrit déjà la structure de dossiers, le contenu des fichiers et les champs à demander.
- À terme, proposer une **marketplace** consultable via `geneser create` (recherche, tri par score) — après la v1.
- **Maintenant (v0.1 → v0.2) : l'entrée est un unique template lié**, pas un catalogue hardcodé.

## Flux cible (v0.1 → v0.2)

```
Entrée : un template lié (dossier / URL git)

1. L'utilisateur linke son template :  geneser create --from ./mon-template  ou  --from https://github.com/org/brick.git
2. Le CLI intercepte le template :
   - lit brick.yaml  →  liste les champs à demander (vars)
   - génère le questionnaire (prompts) automatiquement
3. L'utilisateur renseigne tous les champs
4. Le CLI génère le projet Flutter boilerplate :
   - structure de dossiers telle que définie dans le template (__brick__/)
   - contenu des fichiers tel que défini dans le template (Mustache {{vars}})
   - flutter create + flutter pub get + git init
```

## Évolution prévue (post-v1) : marketplace

- `geneser create` sans `--from` affiche la marketplace : templates avec meilleurs scores, recherche, filtres.
- `geneser list` / `geneser search <query>` pour explorer le registre distant.
- Tri par score, downloads, compatibilité features.

# INTERFACE (actuelle v0.1 — hardcodée, sera remplacée par --from)

```bash
>>> geneser

<<< Nom du projet

<<< choisir des templates.
  exemple : CodeWithAndrea Template , MVVM simple.
  
<<< cocher les librairies tierces à utiliser : Firebase , Supabase .

<<< Cocher les features à implémenter
    exemple :  authentification , notifications push .

```

# INTERFACE CIBLE (v0.2 — template lié)

```bash
>>> geneser create --from ./templates/clean_arch
<<< Questionnaire auto-généré depuis brick.yaml (project_name, organization, description, ...)
<<< Génération : structure + contenu depuis __brick__/ → projet Flutter prêt

>>> geneser create --from https://github.com/user/flutter-starter.git --name my_app --yes
<<< Mode non-interactif : vars passées en flags
```



# ARCHITECTURE — découplée (plus de dépendance à l'archi locale)

- **Moteur Dart (`geneser-cli`)** : interpréteur du template. Ne connaît aucune archi en dur. Il parse `brick.yaml`, génère le questionnaire, exécute les commandes de base et applique `__brick__/`.
- **Template Brick** : contient tout — questionnaires (`brick.yaml` vars) + architecture de dossiers (`__brick__/` ) + contenu de chaque fichier (`{{vars}}`).

> Conséquence : on ne dépend plus de l'architecture locale. Chaque template apporte sa propre archi ; le moteur se contente d'interpréter.

**NB — commandes dans le template :** un template peut utiliser des commandes pour générer un projet de base (ex. `flutter create`). Le moteur attend que la commande soit finie et ait bien généré le projet avant de générer les dossiers nécessaires (`lib/src/services/generator_service.dart:88-94` : `await _runFlutterCreate` puis `await _applyBrick`).

# ADMINISTRATION : définition d'un template lié (format cible v0.2)

Un template est un **dossier Mason** linkable (local ou git). Format précis :

```
mon-template/
├── brick.yaml              # métadonnées + champs à demander (questionnaire)
│   name: clean_arch
│   description: Clean Architecture + Riverpod
│   vars:
│     project_name: {type: string, prompt: "Nom du projet ?"}
│     organization: {type: string, default: com.example}
│     use_firebase: {type: boolean, default: false}
└── __brick__/              # structure + contenu à générer (Mustache)
    ├── pubspec.yaml        # name: {{project_name}}
    ├── lib/
    │   ├── main.dart       # contenu avec {{project_name}}
    │   ├── core/
    │   └── features/
    └── test/
```

- `brick.yaml` = **les champs à demander** → le CLI génère le questionnaire automatiquement.
- `__brick__/` = **structure de dossiers + contenu des fichiers** → copié tel quel avec substitution `{{vars}}`.

Exemple YAML legacy (conservé pour référence) :

```
version: 12
name: 15

folder structure:
  - repository.
    template:
      
  - service.
  - route
  - state
  - screen
  - shared
```


# TECHNOLOGIES D'implémentation

- Dart (CLI)
- Mason (moteur de templates) — brick.yaml + __brick__/
- Configuration de template en fichiers .yaml + Mustache
- Registry distant (marketplace post-v1) : YAML + scores
