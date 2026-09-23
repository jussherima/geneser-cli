# Geneser — Vision produit

> Document de référence produit. Complémente `CDC.md` (réflexion initiale).
> Version : 0.1 — 2026-04-17

---

## 1. Pitch

**🇬🇧** *Geneser — skip the Flutter boilerplate. Compose your stack, ship faster.*

**🇫🇷** *Geneser — zéro boilerplate Flutter. Compose ta stack, livre plus vite.*

**Promesse mesurable :** passer de `flutter create` à **« je code ma vraie feature »** en **moins de 60 secondes**, avec routing, state management, theming, structure de dossiers et tests initiaux déjà câblés.

---

## 2. Le problème

Quand un développeur Flutter démarre un projet sérieux, il a aujourd'hui trois options, toutes mauvaises :

| Option | Problème |
|---|---|
| `flutter create` | Squelette nu. Il faut tout câbler soi-même (routing, state, theme, structure). 2 à 3 jours perdus. |
| `very_good_cli` | Lourd, dogmatique (Bloc obligatoire), anglophone uniquement, pas adapté à tous les projets. |
| Cloner un repo GitHub | Pas de paramétrisation. Code à renommer manuellement. Dépendances souvent obsolètes. |

**Résultat :** la majorité des projets démarrent avec une architecture bancale ou surdimensionnée. Le temps perdu sur le boilerplate répétitif est la frustration #1 des devs Flutter pragmatiques.

Le vrai pain point, résumé par l'utilisateur : *« ne pas perdre de temps à créer `route.dart` »*.

---

## 3. Utilisateur cible

### Persona principal : **« The Pragmatic Shipper »**

- Code Flutter régulièrement (solo, freelance, startup, agence).
- N'a pas envie d'apprendre 3 architectures avant de démarrer.
- N'a pas envie d'un outil qui impose Bloc + 50 fichiers.
- Juge la qualité au **time-to-first-feature**.
- International (Amérique, Europe, Asie, Afrique) → **anglais obligatoire**.

**Sa frustration #1 :** *« Pourquoi je recâble go_router, theme, ErrorBoundary et l10n à chaque projet ? »*

**Sa question :** *« Can I just pick my pieces and start coding ? »*

### Personas secondaires

- Agences Flutter qui veulent standardiser leurs livrables.
- Formateurs et étudiants (Flutter est enseigné en école).
- Seniors qui prototypent vite.

---

## 4. Positionnement

```
                    Opinionné ◄──────────────────► Flexible
                        │
  very_good_cli  ───────┤
  (Bloc imposé)         │
                        │
  Clone GitHub  ────────┼──── flutter create (nu)
                        │
                        │
                        └──── Geneser 🎯
                              (composition curatée)
```

**Geneser occupe l'espace vide :** flexible mais pas nu, rapide mais pas dogmatique, curaté mais communautaire.

### Différence fondamentale vs `very_good_cli`

- `very_good_cli` = produit **fermé** avec templates codés en dur.
- `geneser` = plateforme **ouverte** où la communauté publie ses templates via PR.

---

## 5. Principes directeurs

En cas d'arbitrage, ces principes tranchent :

1. **Clarté avant richesse.** Mieux vaut 5 templates excellents que 30 médiocres.
2. **Autonomie du projet généré.** Une fois généré, le projet n'a **aucune dépendance runtime** à Geneser. Il reste 100 % autonome.
3. **Transparence des choix.** Chaque template généré explique son architecture dans un `ARCHITECTURE.md`. L'utilisateur ne copie pas aveuglément — il comprend.
4. **Communauté avant contrôle.** Geneser est un hub, pas un gardien. Les templates viennent de contributeurs identifiés, pas d'une entité unique.

---

## 6. Ce que Geneser est / n'est pas

### ✅ Ce que Geneser est

- Un **CLI** qui génère un projet Flutter à partir d'**un unique template lié** (dossier local ou URL git). Le template contient déjà : les champs à demander, la structure de dossiers et le contenu des fichiers.
- Flux : `link template → questionnaire auto-généré depuis brick.yaml → projet Flutter avec structure + contenu`.
- Après la v1 : **marketplace** consultable via `geneser create` / `geneser list` (recherche, tri par score) — évolution du même mécanisme.
- Un outil **bilingue** (anglais par défaut, français en secondaire).
- **Idempotent** : `geneser add <feature>` ajoute proprement sur un projet existant.

### Modèle de templating (v0.2 cible)

- **Entrée** : un dossier template à linker (`--from ./mon-template` ou `--from https://github.com/org/brick.git`), pas un choix dans un catalogue hardcodé.
- **Architecture découplée (plus de dépendance à l'archi locale)** :
  - **Moteur Dart (`geneser-cli`)** = interpréteur du template. Il ne connaît aucune architecture en dur ; il orchestre, attend les commandes et génère.
  - **Template Brick** = porte tout : questionnaires (`brick.yaml` vars) + architecture de dossiers (`__brick__/`) + contenu de chaque fichier à générer (Mustache `{{vars}}`).
- **Template = brick.yaml + __brick__/** :
  - `brick.yaml` déclare `vars` → questionnaire généré automatiquement par le CLI.
  - `__brick__/` décrit la structure de dossiers + le contenu des fichiers.
- **Sortie** : projet Flutter boilerplate complet (`flutter create` + overlay + `pub get` + `git init`), sans dépendance runtime à Geneser.
- **NB — commandes dans le template** : le template peut déclarer des commandes de base (ex. `flutter create`). Le moteur attend que chaque commande termine et ait bien généré le projet avant de créer les dossiers/fichiers nécessaires (`lib/src/services/generator_service.dart:88-94` : `await _runFlutterCreate` puis `await _applyBrick`).

### ❌ Ce que Geneser n'est pas

| Pas ça | Pourquoi |
|---|---|
| Un remplacement de `flutter create` | On l'utilise en interne, on ne le remplace pas. |
| Un framework | Aucun code runtime dans le projet généré qui dépend de Geneser. |
| Un outil dogmatique sur une architecture | Contrairement à `very_good_cli`. On propose, on n'impose pas. |
| Un IDE ou plugin | Plus tard (v2.x), pas en MVP. |
| Un gestionnaire de dépendances | `pub` fait déjà ça très bien. |
| Un outil de déploiement | Hors scope. |
| Un outil payant | Gratuit à vie, licence MIT. |

---

## 7. Scope du MVP (v0.1.0)

### Principe : **un MVP minuscule pour valider la mécanique**

Mieux vaut un template parfaitement exécuté que dix bancals.

### Contenu du MVP (v0.1 — hardcodé, en transition vers template lié)

- **1 template hardcodé** : *Starter Riverpod + go_router* (sera le premier template lié de référence).
  - Structure de dossiers claire (`lib/features/`, `lib/shared/`, `lib/routing/`).
  - Riverpod configuré avec `ProviderScope`.
  - go_router avec 2 routes d'exemple.
  - Theme clair/sombre toggleable.
  - Tests unitaires initiaux qui passent.

- **2 features cochables** (briques locales) :
  - `auth_firebase` — authentification email + Google via Firebase.
  - `theming_dark_light` — gestion du thème persistée.

- **Hooks post-génération** :
  - `flutter pub get` automatique.
  - `git init` + premier commit.
  - `dart run build_runner build` si nécessaire.

### Cible v0.2 — template lié (priorité)

- Entrée unique : `geneser create --from <path|url>` (dossier à linker).
- Le template embarque `brick.yaml` (champs à demander) + `__brick__/` (structure + contenu).
- Questionnaire auto-généré depuis `vars`, puis génération Flutter complète.
- Rétrocompatibilité : ` --template starter_riverpod_gorouter` reste supporté via `GENESER_BRICKS_DIR`.

### Stack technique

- **Langage du CLI** : Dart.
- **Moteur de templates** : Mason (dépendance).
- **Prompts interactifs** : `mason_logger` + `interact`.
- **Distribution** : `pub.dev` (installation via `dart pub global activate geneser`).
- **Registre initial** : repo GitHub `geneser-bricks` (Mason via git URL).

### Critères de succès du MVP

- [ ] `geneser create` génère un projet fonctionnel en < 60 secondes.
- [ ] Le projet généré compile et lance au premier essai.
- [ ] Les tests initiaux passent.
- [ ] `geneser add auth_firebase` fonctionne sur un projet existant sans casse.
- [ ] La doc d'installation tient en une page.

---

## 8. Gouvernance et licence

### Licence

**MIT License.** Permissive, adoption entreprise facile, standard de l'écosystème Dart.

### Organisation GitHub

```
github.com/geneser/
├── geneser              ← le CLI (Dart, publié sur pub.dev)
├── geneser-bricks       ← le registre officiel (templates + features)
├── geneser-docs         ← site de doc (Docusaurus ou VitePress)
└── .github              ← templates d'issues/PR partagés
```

### Gouvernance minimale (dès le jour 1)

- `CONTRIBUTING.md` clair : comment proposer un nouveau template.
- `CODE_OF_CONDUCT.md` (Contributor Covenant standard).
- Semantic versioning strict + changelog automatique.
- GitHub Discussions comme forum initial (pas de Discord tant que < 500 utilisateurs).
- Modération : 1 mainteneur principal + 2 reviewers volontaires minimum.

### Processus de contribution d'un template

1. Fork du repo `geneser-bricks`.
2. Ajout de la brique dans `templates/<nom>/` ou `features/<nom>/`.
3. Mise à jour du `registry.yaml`.
4. PR avec description + preview d'un projet généré.
5. Review par un mainteneur (qualité, sécurité, licence).
6. Merge + publication automatique via CI.

---

## 9. Roadmap

### v0.1.0 — MVP (8 semaines)

- 1 template, 2 features, CLI fonctionnel.
- Publication sur pub.dev.
- Doc d'installation + tutorial en 1 page.

### v0.2.0 — Template lié (6 semaines)

- Support `geneser create --from <path|git-url>` : template = dossier à linker.
- `brick.yaml` = champs à demander (questionnaire auto), `__brick__/` = structure + contenu.
- Mode non-interactif : `geneser create --from ./tpl --name my_app --yes` (+ vars passées en flags).
- Fix `GeneratorService.resolveBrickPath` pour binaires compilés (`GENESER_BRICKS_DIR` + `resolvedExecutable`).

### v0.3.0 — Catalogue initial (3 mois)

- 3 templates liés de référence (Clean Architecture, MVVM simple, Starter minimaliste).
- 5 features (notifications push, i18n, API REST, onboarding, splash).
- `geneser list` affiche le catalogue local + distant (cache 1h).

### v1.0.0 — Marketplace (6 mois)

- `geneser create` sans `--from` affiche la marketplace : recherche, tri par score, filtres.
- `geneser search <query>` + `geneser list --refresh`.
- API CLI stable, versionning strict, doc Docusaurus, tests E2E par template.
- Contributions communautaires fluides (score, downloads).

### v2.x — Extensions (12 mois et au-delà)

- Plugin VSCode pour générer sans CLI.
- Landing page publique (`geneser.dev`).
- Publication des templates officiels sur BrickHub.
- Système de templates premium pour entreprises (optionnel, si demande).
- Monorepos Melos supportés.

---

## 10. Questions ouvertes

À trancher plus tard, n'empêchent pas le démarrage :

- **Nom définitif** : garder `geneser` ou chercher plus mémorable (`flick`, `scaff`, `flutter_compose`) ? Vérifier la disponibilité sur pub.dev, GitHub et `.dev`.
- **Choix du 2e template pour v0.2** : Clean Architecture, MVVM, autre ?
- **Support Melos** (monorepos) : à partir de quelle version ?
- **Variables avancées** : gestion des secrets (Firebase config, API keys) lors de la génération ?
- **Télémétrie opt-in** : collecter des stats d'usage anonymes pour prioriser le roadmap ?
- **Internationalisation du CLI** : uniquement EN/FR, ou préparer l'infra pour ES/PT/DE plus tard ?

---

## Annexes

- `CDC.md` — cahier des charges initial (français, document d'origine).
- `README.md` — à rédiger pour le repo GitHub public.
- `CONTRIBUTING.md` — à rédiger avant d'ouvrir le repo aux PRs.
