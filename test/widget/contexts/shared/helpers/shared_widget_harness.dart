import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';
import 'package:mobile/shared/interfaces/widgets/scaffold_with_nav_bar.dart';

/// A [NotificationsCubit] stand-in for the shared widgets.
///
/// The real cubit registers a OneSignal foreground listener inside its
/// constructor, which is plugin work a widget test cannot perform. Because
/// [ClairAppBar] reaches the cubit through get_it and hands it to a
/// `BlocBuilder`, this double has to be a genuine `Cubit` so the shell gets a
/// live `state` and `stream`. It therefore extends `Cubit` directly and only
/// overrides the entry points, keeping [NotificationsState] real.
class FakeNotificationsCubit extends Cubit<NotificationsState>
    implements NotificationsCubit {
  FakeNotificationsCubit([NotificationsState? initialState])
    : super(initialState ?? const NotificationsState());

  /// Number of times a widget asked the cubit to load notifications.
  int loadNotificationsCalls = 0;

  /// The `isRefresh` flag of every `loadNotifications` call, in order.
  final List<bool> refreshFlags = <bool>[];

  /// Number of times a widget asked the cubit for the next page.
  int loadMoreCalls = 0;

  @override
  Future<void> loadNotifications({bool isRefresh = false}) async {
    loadNotificationsCalls++;
    refreshFlags.add(isRefresh);
  }

  @override
  Future<void> loadMoreNotifications() async {
    loadMoreCalls++;
  }

  @override
  void markAllAsSeen() {
    emit(state.copyWith(lastSeenElements: state.totalElements));
  }

  @override
  void reset() => emit(const NotificationsState());
}

/// Registers [cubit] as the notifications cubit the shared widgets read from
/// get_it, and drops the registration when the test ends so state cannot leak
/// into the next test or into another suite.
void registerSharedNotificationsCubit(NotificationsCubit cubit) {
  getIt.registerSingleton<NotificationsCubit>(cubit);
  addTearDown(() async {
    await getIt.reset();
    await cubit.close();
  });
}

/// Wraps [child] with the localization harness the shared widgets need,
/// because the navigation shell reads `AppLocalizations.of(context)!`.
Widget sharedTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
    home: Scaffold(body: child),
  );
}

/// The location the router is currently showing.
String currentLocation(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.toString();

/// Builds a router that mirrors the real app shell: the three bottom navigation
/// destinations live inside a [ScaffoldWithNavBar], and `/settings` and
/// `/notifications` sit outside it, which is what [ClairAppBar] pushes to.
GoRouter sharedShellRouter({String initialLocation = '/analytics'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            ScaffoldWithNavBar(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: '/analytics',
            builder: (BuildContext context, GoRouterState state) =>
                const Center(child: Text('Analytics page')),
          ),
          GoRoute(
            path: '/alerts',
            builder: (BuildContext context, GoRouterState state) =>
                const Center(child: Text('Alerts page')),
          ),
          GoRoute(
            path: '/spaces',
            builder: (BuildContext context, GoRouterState state) =>
                const Center(child: Text('Spaces page')),
          ),
          GoRoute(
            path: '/spaces/:organizationId',
            builder: (BuildContext context, GoRouterState state) => Center(
              child: Text('Space ${state.pathParameters['organizationId']}'),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) =>
            const Center(child: Text('Settings page')),
      ),
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) =>
            const Center(child: Text('Notifications page')),
      ),
    ],
  );
}

/// How many pages the router stack holds, which is how a pushed page becomes
/// observable: the reported location keeps pointing at the bottom of the stack
/// while a page sits on top of it, so stack depth is the reliable signal for a
/// `push`.
int routeDepth(GoRouter router) =>
    router.routerDelegate.currentConfiguration.matches.length;

/// Builds a flat router that renders [child] at [initialLocation], for the app
/// bar tests that need a router but no navigation shell.
GoRouter sharedFlatRouter({
  required PreferredSizeWidget child,
  String initialLocation = '/home',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) => Scaffold(
          appBar: child,
          body: const Center(child: Text('Home body')),
        ),
      ),
      GoRoute(
        path: '/second',
        builder: (BuildContext context, GoRouterState state) => Scaffold(
          appBar: child,
          body: const Center(child: Text('Second body')),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) => Scaffold(
          appBar: child,
          body: const Center(child: Text('Settings page')),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) =>
            const Center(child: Text('Notifications page')),
      ),
    ],
  );
}

/// Builds a router where the app bar only lives on the page that gets pushed on
/// top of a plain page, so a back test sees exactly one back button and the tap
/// is not obscured by the page underneath.
GoRouter sharedPushedAppBarRouter({
  required PreferredSizeWidget child,
  String initialLocation = '/home',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Center(child: Text('Home body'))),
      ),
      GoRoute(
        path: '/second',
        builder: (BuildContext context, GoRouterState state) => Scaffold(
          appBar: child,
          body: const Center(child: Text('Second body')),
        ),
      ),
    ],
  );
}

/// Builds a router that hosts the app bar only on the settings route, so a test
/// can be sitting on `/settings` with exactly one settings action on screen and
/// exercise the app bar's "already here" guard.
GoRouter sharedSettingsAppBarRouter({
  required PreferredSizeWidget child,
  String initialLocation = '/home',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Center(child: Text('Home body'))),
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) => Scaffold(
          appBar: child,
          body: const Center(child: Text('Settings page')),
        ),
      ),
    ],
  );
}

/// Builds a router that mounts the navigation shell on a location the shell
/// itself does not map to any destination, which is how the shell's
/// "unknown location" branch becomes reachable.
GoRouter sharedUnknownRouteRouter({String initialLocation = '/home'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            ScaffoldWithNavBar(
              child: const Center(child: Text('Unmapped page')),
            ),
      ),
    ],
  );
}

/// Pumps [router] inside the localization harness.
Future<void> pumpSharedRouter(
  WidgetTester tester,
  GoRouter router, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp.router(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      routerConfig: router,
    ),
  );
  await settle(tester);
}

/// Advances two frames, which is what a `BlocBuilder` driven state change
/// needs: one frame to deliver the stream event, one to rebuild.
///
/// `pumpAndSettle` is avoided on purpose, because the navigation shell runs an
/// `AnimatedContainer` and the notification button may show a progress
/// indicator while data is loading.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

/// Advances past the 200ms [AnimatedContainer] highlight animation that the
/// navigation shell runs when the selected destination changes.
Future<void> settleNavigation(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}
