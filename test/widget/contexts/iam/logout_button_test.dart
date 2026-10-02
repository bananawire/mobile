import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mobile/iam/interfaces/widgets/logout_button.dart';

class MockTokenLocalStorage extends Mock implements TokenLocalStorage {}

class MockAuthenticationCommandService extends Mock
    implements AuthenticationCommandService {}

class FakeSignOutCommand extends Fake implements SignOutCommand {}

void main() {
  late MockTokenLocalStorage mockLocalStorage;
  late MockAuthenticationCommandService mockCommandService;

  setUpAll(() {
    registerFallbackValue(FakeSignOutCommand());
  });

  setUp(() async {
    await getIt.reset();
    mockLocalStorage = MockTokenLocalStorage();
    mockCommandService = MockAuthenticationCommandService();
    getIt.registerSingleton<TokenLocalStorage>(mockLocalStorage);
    getIt.registerSingleton<AuthenticationCommandService>(mockCommandService);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget createTestWidget() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: LogoutButton()),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('LogoutButton', () {
    testWidgets('should render logout icon button', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets(
      'should trigger signOut, clear tokens, and navigate to /login when tapped with valid token',
      (tester) async {
        // Arrange
        when(
          () => mockLocalStorage.getAccessToken(),
        ).thenAnswer((_) async => 'valid-access-token');
        when(
          () => mockCommandService.handleSignOut(any()),
        ).thenAnswer((_) async => const Right(unit));
        when(() => mockLocalStorage.clearAll()).thenAnswer((_) async {});

        await tester.pumpWidget(createTestWidget());

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockLocalStorage.getAccessToken()).called(1);
        verify(() => mockCommandService.handleSignOut(any())).called(1);
        verify(() => mockLocalStorage.clearAll()).called(1);
        expect(find.text('Login Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'should clear tokens and navigate to /login without calling handleSignOut when token is null',
      (tester) async {
        // Arrange
        when(
          () => mockLocalStorage.getAccessToken(),
        ).thenAnswer((_) async => null);
        when(() => mockLocalStorage.clearAll()).thenAnswer((_) async {});

        await tester.pumpWidget(createTestWidget());

        // Act
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockLocalStorage.getAccessToken()).called(1);
        verifyNever(() => mockCommandService.handleSignOut(any()));
        verify(() => mockLocalStorage.clearAll()).called(1);
        expect(find.text('Login Screen'), findsOneWidget);
      },
    );
  });
}
