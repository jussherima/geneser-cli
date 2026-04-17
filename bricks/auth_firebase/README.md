# auth_firebase

Adds an authentication layer structured for easy Firebase integration:

- `AuthRepository` interface + `AuthUser` model.
- `InMemoryAuthRepository` stub implementation (ships working, no extra setup).
- `authRepositoryProvider` / `authStateProvider` for Riverpod consumers.
- `LoginScreen` widget with email + password form.

## Generated files

- `lib/features/auth/auth_repository.dart`
- `lib/features/auth/in_memory_auth_repository.dart`
- `lib/features/auth/auth_provider.dart`
- `lib/features/auth/login_screen.dart`

## Connecting real Firebase

1. Add deps to `pubspec.yaml`:
   ```yaml
   firebase_core: ^3.0.0
   firebase_auth: ^5.0.0
   ```
2. Run `flutterfire configure` and call `Firebase.initializeApp()` in `main()`.
3. Replace `InMemoryAuthRepository` with a `FirebaseAuthRepository` implementation
   and update `authRepositoryProvider` accordingly.

## Manual wiring

Register the login screen in `lib/app/router.dart`:

```dart
GoRoute(
  path: '/login',
  builder: (context, state) => const LoginScreen(),
),
```
