import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/analytics/interfaces/pages/analytics_cubit.dart';
import 'package:mobile/core/routing/app_router.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/interfaces/pages/confirm_registration/confirm_registration_cubit.dart';
import 'package:mobile/iam/interfaces/pages/login/login_cubit.dart';
import 'package:mobile/iam/interfaces/pages/register/register_cubit.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginCubit extends Mock implements LoginCubit {}

class MockRegisterCubit extends Mock implements RegisterCubit {}

class MockConfirmRegistrationCubit extends Mock
    implements ConfirmRegistrationCubit {}

class MockAnalyticsCubit extends Mock implements AnalyticsCubit {}

/// `ClairAppBar` reads the notifications cubit straight from get_it, so the
/// analytics screen needs one registered even for a routing assertion.
class MockNotificationsCubit extends Mock implements NotificationsCubit {}

/// The route the router settled on, which is where the redirect landed.
String currentLocation(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.toString();

void main() {
  late MockLoginCubit loginCubit;
  late MockRegisterCubit registerCubit;
  late MockConfirmRegistrationCubit confirmRegistrationCubit;
  late MockAnalyticsCubit analyticsCubit;
  late MockNotificationsCubit notificationsCubit;

  setUp(() async {
    AuthSession().setAuthenticated(false);

    loginCubit = MockLoginCubit();
    when(() => loginCubit.state).thenReturn(const LoginState());
    when(() => loginCubit.stream)
        .thenAnswer((_) => const Stream<LoginState>.empty());
    when(() => loginCubit.close()).thenAnswer((_) async {});

    registerCubit = MockRegisterCubit();
    when(() => registerCubit.state).thenReturn(const RegisterState());
    when(() => registerCubit.stream)
        .thenAnswer((_) => const Stream<RegisterState>.empty());
    when(() => registerCubit.close()).thenAnswer((_) async {});

    confirmRegistrationCubit = MockConfirmRegistrationCubit();
    when(() => confirmRegistrationCubit.state)
        .thenReturn(const ConfirmRegistrationState());
    when(() => confirmRegistrationCubit.stream)
        .thenAnswer((_) => const Stream<ConfirmRegistrationState>.empty());
    when(() => confirmRegistrationCubit.close()).thenAnswer((_) async {});

    // AnalyticsScreen starts polling timers on load and its live indicator
    // pulses forever, so the cubit is stubbed rather than driven for real.
    analyticsCubit = MockAnalyticsCubit();
    when(() => analyticsCubit.state).thenReturn(const AnalyticsState());
    when(() => analyticsCubit.stream)
        .thenAnswer((_) => const Stream<AnalyticsState>.empty());
    when(() => analyticsCubit.load()).thenAnswer((_) async {});
    when(() => analyticsCubit.close()).thenAnswer((_) async {});

    notificationsCubit = MockNotificationsCubit();
    when(() => notificationsCubit.state)
        .thenReturn(const NotificationsState());
    when(() => notificationsCubit.stream)
        .thenAnswer((_) => const Stream<NotificationsState>.empty());
    when(
      () => notificationsCubit.loadNotifications(
        isRefresh: any(named: 'isRefresh'),
      ),
    ).thenAnswer((_) async {});
    when(() => notificationsCubit.close()).thenAnswer((_) async {});

    await getIt.reset();
    getIt.registerFactory<LoginCubit>(() => loginCubit);
    getIt.registerFactory<RegisterCubit>(() => registerCubit);
    getIt.registerFactory<ConfirmRegistrationCubit>(
      () => confirmRegistrationCubit,
    );
    getIt.registerFactory<AnalyticsCubit>(() => analyticsCubit);
    getIt.registerFactory<NotificationsCubit>(() => notificationsCubit);
  });

  tearDown(() async {
    await getIt.reset();
    AuthSession().setAuthenticated(false);
  });

  /// `pumpAndSettle` is avoided on purpose: the analytics live indicator runs
  /// an infinitely repeating animation.
  Future<void> pumpRouterApp(WidgetTester tester, GoRouter router) async {
    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
        routerConfig: router,
      ),
    );
    await tester.pump();
  }

  /// Advances frames until the page transition finishes, so the outgoing
  /// screen is no longer in the tree. `pumpAndSettle` cannot be used because
  /// the analytics live indicator repeats forever.
  Future<void> settleRouteTransition(WidgetTester tester) async {
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  group('AppRouter redirect', () {
    testWidgets(
      'should show the login screen when the session is not authenticated',
      (tester) async {
        // Arrange
        final router = AppRouter.router;

        // Act
        await pumpRouterApp(tester, router);

        // Assert
        expect(currentLocation(router), '/login');
        expect(find.text('Login to Clair'), findsOneWidget);
      },
    );

    testWidgets(
      'should redirect to the login screen when an unauthenticated user '
      'requests a protected route',
      (tester) async {
        // Arrange
        final router = AppRouter.router;
        await pumpRouterApp(tester, router);

        // Act
        router.go('/analytics');
        await tester.pump();
        await tester.pump();

        // Assert
        expect(currentLocation(router), '/login');
        expect(find.text('Login to Clair'), findsOneWidget);
        expect(find.text('Air Quality'), findsNothing);
      },
    );

    testWidgets(
      'should redirect to the analytics screen when an authenticated user '
      'lands on the login screen',
      (tester) async {
        // Arrange
        AuthSession().setAuthenticated(true);
        final router = AppRouter.router;

        // Act
        await pumpRouterApp(tester, router);

        // Assert
        expect(currentLocation(router), '/analytics');
        expect(find.text('Air Quality'), findsOneWidget);
        expect(find.text('Login to Clair'), findsNothing);
      },
    );

    for (final String authRoute in <String>['/register', '/confirm-registration']) {
      testWidgets(
        'should redirect to the analytics screen when an authenticated user '
        'requests $authRoute',
        (tester) async {
          // Arrange
          AuthSession().setAuthenticated(true);
          final router = AppRouter.router;
          await pumpRouterApp(tester, router);

          // Act
          router.go(authRoute);
          await tester.pump();
          await tester.pump();

          // Assert
          expect(currentLocation(router), '/analytics');
          expect(find.text('Air Quality'), findsOneWidget);
        },
      );
    }

    testWidgets(
      'should keep an authenticated user on the analytics screen when '
      'requesting a protected route',
      (tester) async {
        // Arrange
        AuthSession().setAuthenticated(true);
        final router = AppRouter.router;
        await pumpRouterApp(tester, router);

        // Act
        router.go('/analytics');
        await tester.pump();
        await tester.pump();

        // Assert — no bounce back to the login screen.
        expect(currentLocation(router), '/analytics');
        expect(find.text('Air Quality'), findsOneWidget);
        expect(find.text('Login to Clair'), findsNothing);
      },
    );

    testWidgets(
      'should stay on the login screen without ping-ponging while the session '
      'is still loading',
      (tester) async {
        // Arrange — the session stays unauthenticated until the stored token
        // has been verified, and the login screen is the current location.
        final router = AppRouter.router;
        await pumpRouterApp(tester, router);

        // Act — a protected route is requested and the router keeps
        // re-evaluating the redirect on every notified frame.
        router.go('/analytics');

        // Assert
        final observedLocations = <String>[currentLocation(router)];
        for (var frame = 0; frame < 3; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
          observedLocations.add(currentLocation(router));
        }

        expect(observedLocations, everyElement('/login'));
        expect(find.text('Login to Clair'), findsOneWidget);
        expect(find.text('Air Quality'), findsNothing);
      },
    );

    testWidgets(
      'should move an unauthenticated user to the analytics screen once the '
      'session becomes authenticated',
      (tester) async {
        // Arrange
        final router = AppRouter.router;
        await pumpRouterApp(tester, router);
        expect(find.text('Login to Clair'), findsOneWidget);

        // Act — the session restore succeeds and notifies the router.
        AuthSession().setAuthenticated(true);
        await settleRouteTransition(tester);

        // Assert
        expect(currentLocation(router), '/analytics');
        expect(find.text('Air Quality'), findsOneWidget);
        expect(find.text('Login to Clair'), findsNothing);
      },
    );

    testWidgets(
      'should move an authenticated user back to the login screen once the '
      'session is invalidated',
      (tester) async {
        // Arrange
        AuthSession().setAuthenticated(true);
        final router = AppRouter.router;
        await pumpRouterApp(tester, router);

        // Act
        AuthSession().setAuthenticated(false);
        await settleRouteTransition(tester);

        // Assert
        expect(currentLocation(router), '/login');
        expect(find.text('Login to Clair'), findsOneWidget);
        expect(find.text('Air Quality'), findsNothing);
      },
    );
  });
}