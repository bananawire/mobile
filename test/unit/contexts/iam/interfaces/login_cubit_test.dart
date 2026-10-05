import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/commands/authenticate_with_google.command.dart';
import 'package:mobile/iam/domain/model/commands/sign_in.command.dart';
import 'package:mobile/iam/interfaces/pages/login/login_cubit.dart';
import 'package:mobile/iam/interfaces/rest/resources/authenticated_user_resource.resource.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/iam_test_doubles.dart';

void main() {
  late MockAuthenticationCommandService commandService;
  late MockGoogleIdTokenProvider googleIdTokenProvider;
  late LoginCubit cubit;

  setUpAll(registerIamFallbackValues);

  setUp(() {
    commandService = MockAuthenticationCommandService();
    googleIdTokenProvider = MockGoogleIdTokenProvider();
    cubit = LoginCubit(commandService, googleIdTokenProvider);
  });

  tearDown(() => cubit.close());

  test('should start idle, without error and without success', () {
    // Assert
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.isSuccess, isFalse);
  });

  group('LoginCubit.signIn', () {
    blocTest<LoginCubit, LoginState>(
      'should flag loading and then success when the credentials are accepted',
      setUp: () {
        when(() => commandService.handleSignIn(any()))
            .thenAnswer((_) async => Right(IamFixtures.authenticatedUser));
      },
      build: () => cubit,
      act: (cubit) => cubit.signIn(
        email: IamFixtures.email,
        password: IamFixtures.password,
      ),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isSuccess, 'isSuccess', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
      verify: (_) {
        final command = verify(() => commandService.handleSignIn(captureAny()))
            .captured
            .single as SignInCommand;
        expect(command.email.address, IamFixtures.email);
        expect(command.password.value, IamFixtures.password);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'should report the failure message when the credentials are rejected',
      setUp: () {
        when(() => commandService.handleSignIn(any())).thenAnswer(
          (_) async => const Left(Failure('Invalid email or password.')),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.signIn(
        email: IamFixtures.email,
        password: IamFixtures.password,
      ),
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isSuccess, 'isSuccess', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', 'Invalid email or password.'),
      ],
      verify: (_) => verify(() => commandService.handleSignIn(any())).called(1),
    );

    blocTest<LoginCubit, LoginState>(
      'should not reach the command service when the email is malformed',
      build: () => cubit,
      act: (cubit) => cubit.signIn(email: 'not-an-email', password: IamFixtures.password),
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', 'Invalid email address format'),
      ],
      verify: (_) => verifyNever(() => commandService.handleSignIn(any())),
    );

    blocTest<LoginCubit, LoginState>(
      'should not reach the command service when the password is too weak',
      build: () => cubit,
      act: (cubit) => cubit.signIn(email: IamFixtures.email, password: 'weak'),
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              startsWith('Password must'),
            ),
      ],
      verify: (_) => verifyNever(() => commandService.handleSignIn(any())),
    );

    blocTest<LoginCubit, LoginState>(
      'should surface the raw message when the command service throws unexpectedly',
      setUp: () {
        when(() => commandService.handleSignIn(any()))
            .thenThrow(StateError('unexpected state'));
      },
      build: () => cubit,
      act: (cubit) => cubit.signIn(
        email: IamFixtures.email,
        password: IamFixtures.password,
      ),
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('unexpected state'),
            ),
      ],
    );

    test(
      'should issue a second request while the first one is still pending because the cubit has no in-flight guard',
      () async {
        // Arrange
        final completer = Completer<Either<Failure, AuthenticatedUserResource>>();
        when(() => commandService.handleSignIn(any())).thenAnswer((_) => completer.future);

        // Act
        final first =
            cubit.signIn(email: IamFixtures.email, password: IamFixtures.password);
        await Future<void>.delayed(Duration.zero);
        final second =
            cubit.signIn(email: IamFixtures.email, password: IamFixtures.password);
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(cubit.state.isLoading, isTrue);
        verify(() => commandService.handleSignIn(any())).called(2);

        // Act
        completer.complete(Right(IamFixtures.authenticatedUser));
        await Future.wait([first, second]);

        // Assert
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.isSuccess, isTrue);
      },
    );

    test(
      'should accept a second submit once the first request settled',
      () async {
        // Arrange
        when(() => commandService.handleSignIn(any()))
            .thenAnswer((_) async => Right(IamFixtures.authenticatedUser));

        // Act
        await cubit.signIn(email: IamFixtures.email, password: IamFixtures.password);
        await cubit.signIn(email: IamFixtures.email, password: IamFixtures.password);

        // Assert
        verify(() => commandService.handleSignIn(any())).called(2);
      },
    );

    test(
      'should keep the loading flag set while a request is still pending',
      () async {
        // Arrange
        final completer = Completer<Either<Failure, AuthenticatedUserResource>>();
        when(() => commandService.handleSignIn(any())).thenAnswer((_) => completer.future);

        // Act
        final pending = cubit.signIn(
          email: IamFixtures.email,
          password: IamFixtures.password,
        );
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(cubit.state.isLoading, isTrue);

        // Act
        completer.complete(Right(IamFixtures.authenticatedUser));
        await pending;

        // Assert
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.isSuccess, isTrue);
      },
    );
  });

  group('LoginCubit.signInWithGoogle', () {
    blocTest<LoginCubit, LoginState>(
      'should flag loading and then success when the id token is accepted',
      setUp: () {
        when(() => googleIdTokenProvider.fetchIdToken())
            .thenAnswer((_) async => IamFixtures.googleIdToken);
        when(() => commandService.handleAuthenticateWithGoogle(any()))
            .thenAnswer((_) async => Right(IamFixtures.authenticatedUser));
      },
      build: () => cubit,
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.isSuccess, 'isSuccess', isTrue),
      ],
      verify: (_) {
        verify(() => googleIdTokenProvider.fetchIdToken()).called(1);
        final command = verify(
          () => commandService.handleAuthenticateWithGoogle(captureAny()),
        ).captured.single as AuthenticateWithGoogleCommand;
        expect(command.idToken.token, IamFixtures.googleIdToken);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'should report the failure message when the backend rejects the id token',
      setUp: () {
        when(() => googleIdTokenProvider.fetchIdToken())
            .thenAnswer((_) async => IamFixtures.googleIdToken);
        when(() => commandService.handleAuthenticateWithGoogle(any())).thenAnswer(
          (_) async => const Left(Failure('User already exists.')),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.errorMessage, 'errorMessage', 'User already exists.')
            .having((s) => s.isSuccess, 'isSuccess', isFalse),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should surface the provider error and skip the command service when the user cancels',
      setUp: () {
        when(() => googleIdTokenProvider.fetchIdToken())
            .thenThrow(Exception('Google sign-in was cancelled'));
      },
      build: () => cubit,
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Google sign-in was cancelled'),
            ),
      ],
      verify: (_) =>
          verifyNever(() => commandService.handleAuthenticateWithGoogle(any())),
    );

    blocTest<LoginCubit, LoginState>(
      'should report the value object error when the provider returns a blank id token',
      setUp: () {
        when(() => googleIdTokenProvider.fetchIdToken()).thenAnswer((_) async => '   ');
      },
      build: () => cubit,
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<LoginState>()
            .having((s) => s.errorMessage, 'errorMessage', 'Google ID token is required'),
      ],
      verify: (_) =>
          verifyNever(() => commandService.handleAuthenticateWithGoogle(any())),
    );
  });
}

