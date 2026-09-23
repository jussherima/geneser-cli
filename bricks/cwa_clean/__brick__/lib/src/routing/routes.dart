import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:{{project_name}}/src/routing/not_found_screen.dart';
import 'package:{{project_name}}/src/features/home/presentation/home_screen.dart';
{{#with_profile}}import 'package:{{project_name}}/src/features/profile/presentation/profile_screen.dart';{{/with_profile}}
{{#with_feed}}import 'package:{{project_name}}/src/features/feed/presentation/feed_screen.dart';{{/with_feed}}
{{#with_notifications}}import 'package:{{project_name}}/src/features/notifications/presentation/notifications_screen.dart';{{/with_notifications}}
import 'package:{{project_name}}/src/features/authentication/presentation/signin_screen.dart';
import 'package:{{project_name}}/src/routing/main_shell.dart';

part 'routes.g.dart';

final GlobalKey<NavigatorState> _homeKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final GlobalKey<NavigatorState> _profileKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');
final GlobalKey<NavigatorState> _feedKey = GlobalKey<NavigatorState>(debugLabel: 'feedNav');

const List<TypedRoute<RouteData>> homeRoutes = [TypedGoRoute<HomeRoute>(path: '/home')];
{{#with_feed}}const List<TypedRoute<RouteData>> feedRoutes = [TypedGoRoute<FeedRoute>(path: '/feed')];{{/with_feed}}
{{#with_profile}}const List<TypedRoute<RouteData>> profileRoutes = [TypedGoRoute<ProfileRoute>(path: '/profile')];{{/with_profile}}
{{#with_notifications}}const List<TypedRoute<RouteData>> notificationsRoutes = [TypedGoRoute<NotificationsRoute>(path: '/notifications')];{{/with_notifications}}

const TypedStatefulShellBranch<HomeBranchData> homeBranch = TypedStatefulShellBranch<HomeBranchData>(routes: homeRoutes);
{{#with_feed}}const TypedStatefulShellBranch<FeedBranchData> feedBranch = TypedStatefulShellBranch<FeedBranchData>(routes: feedRoutes);{{/with_feed}}
{{#with_profile}}const TypedStatefulShellBranch<ProfileBranchData> profileBranch = TypedStatefulShellBranch<ProfileBranchData>(routes: profileRoutes);{{/with_profile}}

@TypedStatefulShellRoute<MainShellRouteData>(
  branches: [
    homeBranch,
{{#with_feed}}    feedBranch,{{/with_feed}}
{{#with_profile}}    profileBranch,{{/with_profile}}
  ],
)
class MainShellRouteData extends StatefulShellRouteData {
  const MainShellRouteData();
  @override Widget builder(BuildContext context, GoRouterState state, StatefulNavigationShell shell) => MainShell(navigationShell: shell);
}
class HomeBranchData extends StatefulShellBranchData { static final GlobalKey<NavigatorState> \$navigatorKey = _homeKey; }
{{#with_feed}}class FeedBranchData extends StatefulShellBranchData { static final GlobalKey<NavigatorState> \$navigatorKey = _feedKey; }{{/with_feed}}
{{#with_profile}}class ProfileBranchData extends StatefulShellBranchData { static final GlobalKey<NavigatorState> \$navigatorKey = _profileKey; }{{/with_profile}}

@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData { const HomeRoute(); @override Widget build(BuildContext c, GoRouterState s) => const HomeScreen(); }
{{#with_feed}}@TypedGoRoute<FeedRoute>(path: '/feed')
class FeedRoute extends GoRouteData { const FeedRoute(); @override Widget build(BuildContext c, GoRouterState s) => const FeedScreen(); }{{/with_feed}}
{{#with_profile}}@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData { const ProfileRoute(); @override Widget build(BuildContext c, GoRouterState s) => const ProfileScreen(); }{{/with_profile}}
{{#with_notifications}}@TypedGoRoute<NotificationsRoute>(path: '/notifications')
class NotificationsRoute extends GoRouteData { const NotificationsRoute(); @override Widget build(BuildContext c, GoRouterState s) => const NotificationsScreen(); }{{/with_notifications}}
@TypedGoRoute<SigninRoute>(path: '/signin')
class SigninRoute extends GoRouteData { const SigninRoute(); @override Widget build(BuildContext c, GoRouterState s) => const SigninScreen(); }
@TypedGoRoute<NotFoundRoute>(path: '/404')
class NotFoundRoute extends GoRouteData { const NotFoundRoute(); @override Widget build(BuildContext c, GoRouterState s) => const NotFoundScreen(); }
