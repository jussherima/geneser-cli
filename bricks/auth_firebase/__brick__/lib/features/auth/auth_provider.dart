import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'in_memory_auth_repository.dart';

/// Swap `InMemoryAuthRepository` for your real implementation (Firebase,
/// Supabase, etc.) once it's wired up.
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) => InMemoryAuthRepository());

final StreamProvider<AuthUser?> authStateProvider =
    StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
