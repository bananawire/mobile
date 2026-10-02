import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/sign_out.command.dart';
import 'package:mobile/iam/domain/model/queries/verify_token.query.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/domain/services/authentication.query-service.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mobile/iam/interfaces/pages/dashboard/dashboard_cubit.dart';
import 'package:mobile/iam/interfaces/rest/resources/token_verification_resource.resource.dart';

class MockAuthenticationCommandService extends Mock implements AuthenticationCommandService {}
class MockAuthenticationQueryService extends Mock implements AuthenticationQueryService {}
class MockTokenLocalStorage extends Mock implements TokenLocalStorage {}
class FakeSignOutCommand extends Fake implements SignOutCommand {}
class FakeVerifyTokenQuery extends Fake implements VerifyTokenQuery {}

void main() {
  late MockAuthenticationCommandService mockCommandService;
  late MockAuthenticationQueryService mockQueryService;
  late MockTokenLocalStorage mockLocalStorage;

  const sampleVerification = TokenVerificationResource(
    valid: true,
    userId: 'user-id-123',
    expiresAt: '2026-12-31T23:59:59Z',
  );

  setUpAll(() {
    registerFallbackValue(FakeSignOutCommand());
    registerFallbackValue(FakeVerifyTokenQuery());
  });

  setUp(() {
    mockCommandService = MockAuthenticationCommandService();
    mockQueryService = MockAuthenticationQueryService();
    mockLocalStorage = MockTokenLocalStorage();
    AuthSession().setAuthenticated(false);
  });

  tearDown(() {
    AuthSession().setAuthenticated(false);
  });

  group('DashboardCubit', () {
    test('should have initial state with default values', () {
      final cubit = DashboardCubit(mockCommandService, mockQueryService, mockLocalStorage);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.email, isNull);
      expect(cubit.state.isAuthenticated, isFalse);
    });

    blocTest<DashboardCubit, DashboardState>(
      'should emit unauthenticated when stored token is null',
      build: () {
        when(() => mockLocalStorage.getAccessToken()).thenAnswer((_) async => null);
        when(() => mockLocalStorage.getEmail()).thenAnswer((_) async => null);
        return DashboardCubit(mockCommandService, mockQueryService, mockLocalStorage);
      },
      act: (cubit) => cubit.loadSession(),
      expect: () => [
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) {
        verifyNever(() => mockQueryService.handleVerifyToken(any()));
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'should emit unauthenticated when stored token is empty string',
      build: () {
        when(() => mockLocalStorage.getAccessToken()).thenAnswer((_) async => '');
        when(() => mockLocalStorage.getEmail()).thenAnswer((_) async => null);
        return DashboardCubit(mockCommandService, mockQueryService, mockLocalStorage);
      },
      act: (cubit) => cubit.loadSession(),
      expect: () => [
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'should emit authenticated with email and update AuthSession when verifyToken succeeds',
      build: () {
        when(() => mockLocalStorage.getAccessToken()).thenAnswer((_) async => 'valid-jwt');
        when(() => mockLocalStorage.getEmail()).thenAnswer((_) async => 'user@example.com');
        when(() => mockQueryService.handleVerifyToken(any()))
            .thenAnswer((_) async => const Right(sampleVerification));
        return DashboardCubit(mockCommandService, mockQueryService, mockLocalStorage);
      },
      act: (cubit) => cubit.loadSession(),
      expect: () => [
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isTrue)
            .having((s) => s.email, 'email', 'user@example.com'),
      ],
      verify: (_) {
        expect(AuthSession().isAuthenticated, isTrue);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'should emit unauthenticated with errorMessage and update AuthSession when verifyToken fails',
      build: () {
        when(() => mockLocalStorage.getAccessToken()).thenAnswer((_) async => 'expired-jwt');
        when(() => mockLocalStorage.getEmail()).thenAnswer((_) async => 'user@example.com');
        when(() => mockQueryService.handleVerifyToken(any()))
            .thenAnswer((_) async => const Left(Failure('Session expired. Please sign in again.')));
        return DashboardCubit(mockCommandService, mockQueryService, mockLocalStorage);
      },
      act: (cubit) => cubit.loadSession(),
      expect: () => [
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', 'Session expired. Please sign in again.'),
      ],
      verify: (_) {
        expect(AuthSession().isAuthenticated, isFalse);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'should call handleSignOut and emit unauthenticated on signOut when token is present',
      build: () {
        when(() => mockLocalStorage.getAccessToken()).thenAnswer((_) async => 'active-token');
        when(() => mockCommandService.handleSignOut(any())).thenAnswer((_) async => const Right(unit));
        return DashboardCubit(mockCommandService, mockQueryService, mockLocalStorage);
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) {
        verify(() => mockCommandService.handleSignOut(any())).called(1);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'should skip handleSignOut and emit unauthenticated on signOut when token is null',
      build: () {
        when(() => mockLocalStorage.getAccessToken()).thenAnswer((_) async => null);
        return DashboardCubit(mockCommandService, mockQueryService, mockLocalStorage);
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse),
      ],
      verify: (_) {
        verifyNever(() => mockCommandService.handleSignOut(any()));
      },
    );
  });
}
