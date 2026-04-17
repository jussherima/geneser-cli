# starter_riverpod_gorouter

A pragmatic Flutter starter template with:

- Riverpod for state management
- go_router for navigation
- Light and dark theming with Material 3
- Two example screens (home + about) demonstrating navigation

## Usage with Geneser

```bash
geneser create
```

Select `starter_riverpod_gorouter` when prompted.

## Variables

| Name | Description | Default |
|---|---|---|
| `project_name` | Package name (snake_case) | `my_app` |
| `organization` | Reverse-DNS bundle id | `com.example` |
| `description` | One-line description | `A new Flutter project generated with Geneser.` |

## What Geneser does on top of this brick

When this brick is selected, Geneser orchestrates the following in order:

1. Runs `flutter create` to scaffold the standard Flutter project (platform folders, etc.).
2. Overlays the files from `__brick__/` with your values substituted.
3. Runs `flutter pub get`.
4. Initializes a Git repository and creates the first commit.
