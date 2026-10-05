import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mobile/iam/interfaces/widgets/logout_button.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../../unit/contexts/iam/helpers/iam_test_doubles.dart';

class _LoginPage extends StatelessWidget {
  const _LoginPage();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Login page'));
}

void main() {
  late MockTokenLocalStorage tokenStorage;
  late MockAuthenticationCommandService commandService;
  late GoRouter router;

  setUpAll(registerIamFallbackValues);

  setUp(() {
    tokenStorage = MockTokenLocalStorage();
    commandService = MockAuthenticationCommandService();

    when(() => tokenStorage.clearAll()).thenAnswer((_) async {});
    when(() => commandService.handleSignOut(any()))
        .thenAnswer((_) async => const Right(unit));

    getIt
      ..registerSingleton<TokenLocalStorage>(tokenStorage)
      ..registerSingleton<AuthenticationCommandService>(commandService);

    router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Scaffold(body: LogoutButton()),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const _LoginPage(),
        ),
      ],
    );
  });

  tearDown(() {
    router.dispose();
    getIt.reset();
    AuthSession().setAuthenticated(false);
  });

  group('LogoutButton', () {
    testWidgets('should render the logout icon', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      );

      // Assert
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets(
      'should sign out with the stored token and navigate to the login page',
      (tester) async {
        // Arrange
        when(() => tokenStorage.getAccessToken())
            .thenAnswer((_) async => IamFixtures.accessToken);

        await tester.pumpWidget(
          MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: router,
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();

        // Assert
        final command = verify(() => commandService.handleSignOut(captureAny()))
            .captured
            .single as SignOutCommand;
        expect(command.accessToken.token, IamFixtures.accessToken);
        verify(() => tokenStorage.clearAll()).called(1);
        expect(find.text('Login page'), findsOneWidget);
      },
    );

    testWidgets(
      'should skip the remote sign out but still clear storage when no token is stored',
      (tester) async {
        // Arrange
        when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => null);

        await tester.pumpWidget(
          MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: router,
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();

        // Assert
        verifyNever(() => commandService.handleSignOut(any()));
        verify(() => tokenStorage.clearAll()).called(1);
        expect(find.text('Login page'), findsOneWidget);
      },
    );

    testWidgets(
      'should still navigate to the login page when the remote sign out fails',
      (tester) async {
        // Arrange
        when(() => tokenStorage.getAccessToken())
            .thenAnswer((_) async => IamFixtures.accessToken);
        when(() => commandService.handleSignOut(any()))
            .thenAnswer((_) async => const Left(Failure('Access denied.')));

        await tester.pumpWidget(
          MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: router,
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();

        // Assert
        verify(() => tokenStorage.clearAll()).called(1);
        expect(find.text('Login page'), findsOneWidget);
      },
    );
  });
}

/// Localized delegates for the router based harness.
abstract final class AppLocalizationsDelegates {
  static const List<LocalizationsDelegate<Object>> delegates = <LocalizationsDelegate<Object>>[
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
  ];
}