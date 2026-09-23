import 'package:freezed_annotation/freezed_annotation.dart';
part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
sealed class AppUser with _\$AppUser {
  const factory AppUser.authenticated({required String id, required String email, String? displayName}) = AuthenticatedUser;
  const factory AppUser.notAuthenticated() = NotAuthenticatedUser;
  const factory AppUser.loading() = LoadingUser;
  factory AppUser.fromJson(Map<String, dynamic> j) => _\$AppUserFromJson(j);
}
