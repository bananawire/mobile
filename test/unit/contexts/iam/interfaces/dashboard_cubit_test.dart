import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/model/queries/verify_token.query.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/interfaces/pages/dashboard/dashboard_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/iam_test_doubles.dart';

void main() {
  late MockAuthenticationCommandService commandService;
  late MockAuthenticationQueryService queryService;
  late MockTokenLocalStorage tokenStorage;
  late DashboardCubit cubit;

  setUpAll(registerIamFallbackValues);

  setUp(() {
    commandService = MockAuthenticationCommandService();
    queryService = MockAuthenticationQueryService();
    tokenStorage = MockTokenLocalStorage();
    when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => IamFixtures.accessToken);
    when(() => tokenStorage.getEmail()).thenAnswer((_) async => IamFixtures.email);
    when(() => queryService.handleVerifyToken(any()))
        .thenAnswer((_) async => Right(IamFixtures.validTokenVerification));
    when(() => commandService.handleSignOut(any()))
        .thenAnswer((_) async => const Right(unit));
    cubit = DashboardCubit(commandService, queryService, tokenStorage);
  });

  tearDown(() {
    cubit.close();
    AuthSession().setAuthenticated(false);
  });

  test('should start unauthenticated and idle', () {
    // Assert
    expect(cubit.state.isAuthenticated, isFalse);
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.email, isNull);
  });

  group('DashboardCubit.loadSession', () {
    blocTest<DashboardCubit, DashboardState>(
      'should expose the stored email and mark the session authenticated',
      build: () => cubit,
      act: (cubit) => cubit.loadSession(),
      expect: () => [
        isA<DashboardState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isTrue)
            .having((s) => s.email, 'email', IamFixtures.email),
      ],
      verify: (_) {
        final query = verify(() => queryService.handleVerifyToken(captureAny()))
            .captured
            .single as VerifyTokenQuery;
        expect(query.accessToken.token, IamFixtures.accessToken);
        expect(AuthSession().isAuthenticated, isTrue);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'should end unauthenticated and skip the query when no token is stored',
      setUp: () {
        when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => null);
      },
      build: () => cubit,
      act: (cubit) => cubit.loadSession(),
      expect: () => [
        isA<DashboardState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) => verifyNever(() => queryService.handleVerifyToken(any())),
    );

    blocTest<DashboardCubit, DashboardState>(
      'should end unauthenticated and skip the query when the stored token is empty',
      setUp: () {
        when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => '');
      },
      build: () => cubit,
      act: (cubit) => cubit.loadSession(),
      expect: () => [
        isA<DashboardState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) => verifyNever(() => queryService.handleVerifyToken(any())),
    );

    blocTest<DashboardCubit, DashboardState>(
      'should end unauthenticated and report the failure when the token is rejected',
      setUp: () {
        when(() => queryService.handleVerifyToken(any()))
            .thenAnswer((_) async => const Left(Failure('Session expired. Please sign in again.')));
      },
      build: () => cubit,
      act: (cubit) => cubit.loadSession(),
      expect: () => [
        isA<DashboardState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Session expired. Please sign in again.',
            ),
      ],
      verify: (_) => expect(AuthSession().isAuthenticated, isFalse),
    );

    blocTest<DashboardCubit, DashboardState>(
      'should end authenticated even when the verification reports the token as invalid',
      setUp: () {
        when(() => queryService.handleVerifyToken(any()))
            .thenAnswer((_) async => Right(IamFixtures.invalidTokenVerification));
      },
      build: () => cubit,
      act: (cubit) => cubit.loadSession(),
      expect: () => [
        isA<DashboardState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isAuthenticated, 'isAuthenticated', isTrue),
      ],
    );
  });

  group('DashboardCubit.signOut', () {
    blocTest<DashboardCubit, DashboardState>(
      'should flag loading and then unauthenticated when a token is stored',
      build: () => cubit,
      act: (cubit) => cubit.signOut(),
      expect: () => [
        isA<DashboardState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) {
        final command = verify(() => commandService.handleSignOut(captureAny()))
            .captured
            .single as SignOutCommand;
        expect(command.accessToken.token, IamFixtures.accessToken);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'should skip the remote sign out when no token is stored',
      setUp: () {
        when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => null);
      },
      build: () => cubit,
      act: (cubit) => cubit.signOut(),
      expect: () => [
        isA<DashboardState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) => verifyNever(() => commandService.handleSignOut(any())),
    );
  });
}