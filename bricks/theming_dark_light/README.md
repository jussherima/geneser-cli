# theming_dark_light

Adds a Settings screen with a theme mode toggle (system / light / dark).

## Generated files

- `lib/features/settings/settings_screen.dart` — toggle UI.
- `lib/features/settings/theme_controller.dart` — Riverpod notifier for theme mode.

## Manual wiring

Register the screen as a route in `lib/app/router.dart`:

```dart
GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
),
```

Read `themeModeProvider` from `lib/app/app.dart` to bind the selected mode to
`MaterialApp.router(themeMode: ...)`.
