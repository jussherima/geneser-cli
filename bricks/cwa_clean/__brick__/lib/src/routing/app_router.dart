import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:{{project_name}}/src/routing/routes.dart';
part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: HomeRoute().location,
    debugLogDiagnostics: kDebugMode,
    routes: \$appRoutes,
  );
  ref.onDispose(() => router.dispose());
  return router;
}
