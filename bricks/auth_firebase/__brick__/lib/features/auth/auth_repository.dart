/// Abstraction over the authentication backend.
///
/// Implementations can target Firebase Auth, Supabase, a custom REST API, or
/// a fake repository for testing and local development.
abstract class AuthRepository {
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Stream<AuthUser?> get authStateChanges;
}

class AuthUser {
  const AuthUser({required this.id, required this.email});

  final String id;
  final String email;
}
