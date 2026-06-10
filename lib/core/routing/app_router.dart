import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/analytics/interfaces/pages/analytics_cubit.dart';
import 'package:mobile/analytics/interfaces/pages/analytics_screen.dart';
import 'package:mobile/alerts/interfaces/pages/alerts_cubit.dart';
import 'package:mobile/alerts/interfaces/pages/alerts_screen.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/interfaces/pages/confirm_registration/confirm_registration_cubit.dart';
import 'package:mobile/iam/interfaces/pages/confirm_registration/confirm_registration_screen.dart';
import 'package:mobile/iam/interfaces/pages/login/login_cubit.dart';
import 'package:mobile/iam/interfaces/pages/login/login_screen.dart';
import 'package:mobile/iam/interfaces/pages/register/register_cubit.dart';
import 'package:mobile/iam/interfaces/pages/register/register_screen.dart';
import 'package:mobile/iam/interfaces/pages/settings/settings_cubit.dart';
import 'package:mobile/iam/interfaces/pages/settings/settings_screen.dart';
import 'package:mobile/shared/interfaces/widgets/scaffold_with_nav_bar.dart';
import 'package:mobile/devices/interfaces/pages/organizations/organizations_cubit.dart';
import 'package:mobile/devices/interfaces/pages/organizations/organizations_screen.dart';
import 'package:mobile/devices/interfaces/pages/space_devices/space_devices_cubit.dart';
import 'package:mobile/devices/interfaces/pages/space_devices/space_devices_screen.dart';
import 'package:mobile/devices/interfaces/pages/spaces/spaces_cubit.dart';
import 'package:mobile/devices/interfaces/pages/spaces/spaces_screen.dart';
import 'package:mobile/devices/interfaces/pages/device_detail/device_detail_cubit.dart';
import 'package:mobile/devices/interfaces/pages/device_detail/device_detail_screen.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _authSession = AuthSession();
  static final routeObserver = RouteObserver<PageRoute>();

  static GoRouter get router => GoRouter(
        navigatorKey: _rootNavigatorKey,
        observers: [routeObserver],
        initialLocation: '/login',
        refreshListenable: _authSession,
        redirect: (context, state) {
          final isAuthenticated = _authSession.isAuthenticated;
          final isAuthRoute = state.matchedLocation == '/login' ||
              state.matchedLocation == '/register' ||
              state.matchedLocation == '/confirm-registration';

          if (!isAuthenticated && !isAuthRoute) {
            return '/login';
          }

          if (isAuthenticated && isAuthRoute) {
            return '/analytics';
          }

          return null;
        },
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<LoginCubit>(),
              child: const LoginScreen(),
            ),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<RegisterCubit>(),
              child: const RegisterScreen(),
            ),
          ),
          GoRoute(
            path: '/confirm-registration',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<ConfirmRegistrationCubit>(),
              child: const ConfirmRegistrationScreen(),
            ),
          ),
          ShellRoute(
            builder: (context, state, child) => ScaffoldWithNavBar(child: child),
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => BlocProvider(
                  create: (_) => getIt<AnalyticsCubit>(),
                  child: const AnalyticsScreen(),
                ),
              ),
              GoRoute(
                path: '/alerts',
                builder: (context, state) => BlocProvider(
                  create: (_) => getIt<AlertsCubit>(),
                  child: const AlertsScreen(),
                ),
              ),
              GoRoute(
                path: '/spaces',
                builder: (context, state) => BlocProvider(
                  create: (_) => getIt<OrganizationsCubit>(),
                  child: const OrganizationsScreen(),
                ),
              ),
              GoRoute(
                path: '/spaces/:organizationId',
                builder: (context, state) {
                  final organizationId = state.pathParameters['organizationId']!;
                  final organizationName = state.extra is String ? state.extra as String : null;
                  return BlocProvider(
                    create: (_) => getIt<SpacesCubit>(),
                    child: SpacesScreen(
                      organizationId: organizationId,
                      organizationName: organizationName,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: ':spaceId',
                    builder: (context, state) {
                      final spaceId = state.pathParameters['spaceId']!;
                      final spaceName = state.extra is String ? state.extra as String : null;
                      return BlocProvider(
                        create: (_) => getIt<SpaceDevicesCubit>(),
                        child: SpaceDevicesScreen(
                          spaceId: spaceId,
                          spaceName: spaceName,
                        ),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: '/devices/:deviceId',
                builder: (context, state) {
                  final deviceId = state.pathParameters['deviceId']!;
                  return BlocProvider(
                    create: (_) => getIt<DeviceDetailCubit>()..loadDeviceDetail(deviceId),
                    child: DeviceDetailScreen(deviceId: deviceId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<SettingsCubit>(),
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
        ],
      );
}
