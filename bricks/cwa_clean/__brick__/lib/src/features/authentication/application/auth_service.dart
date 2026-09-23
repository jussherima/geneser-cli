{{#with_auth}}import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:{{project_name}}/src/features/authentication/data/auth_repository.dart';
part 'auth_service.g.dart';

@riverpod
class AuthController extends _\$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String e, String p) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signIn(e, p));
  }
}{{/with_auth}}{{^with_auth}}// disabled{{/with_auth}}
