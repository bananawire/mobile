import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_log.valueobject.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/domain/services/notifications.query-service.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';

import '../../../../unit/contexts/notifications/helpers/notifications_fixtures.dart';

/// A hand written [NotificationsQueryService] that answers scripted pages and
/// records every query, so the widgets can be driven through the real cubit.
class FakeNotificationsQueryService implements NotificationsQueryService {
  FakeNotificationsQueryService();

  /// The answer used when [onQuery] is null. An empty page by default, which
  /// is the quietest starting point for a widget test.
  Either<Failure, NotificationPage> result =
      Right<Failure, NotificationPage>(emptyNotificationsPage);

  /// Decides the answer per query, which makes pagination scripts expressible.
  Either<Failure, NotificationPage> Function(GetNotificationsQuery query)?
      onQuery;

  /// When set, every call waits for this future, which keeps a request pending
  /// long enough to observe the loading surface.
  Future<Either<Failure, NotificationPage>>? pendingResult;

  /// Every query the widgets triggered, in order.
  final List<GetNotificationsQuery> queries = <GetNotificationsQuery>[];

  /// Number of times the service was asked for a page.
  int calls = 0;

  /// The page indices requested so far.
  List<int> get requestedPages => queries.map((query) => query.page).toList();

  @override
  Future<Either<Failure, NotificationPage>> handleGetNotifications(
    GetNotificationsQuery query,
  ) async {
    calls++;
    queries.add(query);
    final pending = pendingResult;
    if (pending != null) {
      return pending;
    }
    final handler = onQuery;
    if (handler != null) {
      return handler(query);
    }
    return result;
  }
}

/// Registers [cubit] as the notifications cubit the shared widgets read from
/// get_it, and drops the registration when the test ends.
void registerNotificationsCubit(NotificationsCubit cubit) {
  getIt.registerSingleton<NotificationsCubit>(cubit);
  addTearDown(() async {
    await getIt.reset();
    await cubit.close();
  });
}

/// Wraps [child] with the localization harness every notifications widget
/// needs, because the screen reads `AppLocalizations.of(context)!`.
Widget notificationsTestApp({
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

/// How many pages the router stack holds, which is how a pushed page becomes
/// observable. The reported `uri` keeps pointing at the bottom of the stack
/// while a page is pushed on top.
int routeDepth(GoRouter router) =>
    router.routerDelegate.currentConfiguration.matches.length;

/// Builds a router that renders [child] on `/home` and [notificationsChild] on
/// `/notifications`, so a notification button can read
/// `GoRouterState.of(context).matchedLocation` and navigate for real.
GoRouter notificationsRouter({
  required Widget child,
  Widget notificationsChild =
      const Scaffold(body: Center(child: Text('Notifications route'))),
  String initialLocation = '/home',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            Scaffold(body: Center(child: child)),
      ),
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) =>
            notificationsChild,
      ),
    ],
  );
}

/// Pumps [router] inside the localization harness.
Future<void> pumpRoutedApp(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    MaterialApp.router(
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
/// `pumpAndSettle` is avoided on purpose, because the notifications surface
/// shows an indeterminate `CircularProgressIndicator` and a `RefreshIndicator`
/// while data is loading.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

/// Builds a real [NotificationLog] with the fields a widget test needs.
NotificationLog buildWidgetNotification({
  String id = 'notification-1',
  String title = 'High temperature',
  String message = 'The kitchen sensor reported 41 degrees',
  bool sent = true,
  String? errorMessage,
  DateTime? createdAt,
}) {
  return buildNotificationLog(
    id: id,
    title: title,
    message: message,
    sent: sent,
    errorMessage: errorMessage,
    createdAt: createdAt,
  );
}

/// Builds a real page holding [notifications].
NotificationPage buildWidgetPage(
  List<NotificationLog> notifications, {
  int totalElements = 0,
  int totalPages = 1,
  int number = 0,
}) {
  return buildNotificationPage(
    notifications,
    totalElements: totalElements,
    totalPages: totalPages,
    size: 20,
    number: number,
  );
}