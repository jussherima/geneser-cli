{{#with_auth}}import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'auth_repository.g.dart';

class AuthRepository {
  Ref ref;
  AuthRepository(this.ref);
  Future<void> signIn(String e, String p) async {}
  Future<void> signOut() async {}
  Future<bool> isAuthenticated() async => false;
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(ref);{{/with_auth}}{{^with_auth}}// auth disabled{{/with_auth}}
