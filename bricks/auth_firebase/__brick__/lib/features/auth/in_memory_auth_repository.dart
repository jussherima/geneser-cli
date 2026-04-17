import 'dart:async';

import 'auth_repository.dart';

/// Development-friendly stub that holds the current user in memory.
///
/// Accepts any email + password of length >= 6. Swap for a real
/// `FirebaseAuthRepository` once Firebase is configured.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository();

  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _current;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (password.length < 6) return null;
    _current = AuthUser(id: 'fake-${email.hashCode}', email: email);
    _controller.add(_current);
    return _current;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }
}
