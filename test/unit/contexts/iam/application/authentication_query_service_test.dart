import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/application/internal/queryservices/authentication_query_service_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/iam_test_doubles.dart';

void main() {
  late MockAuthenticationGateway gateway;
  late AuthenticationQueryServiceImpl queryService;

  setUpAll(registerIamFallbackValues);

  setUp(() {
    gateway = MockAuthenticationGateway();
    queryService = AuthenticationQueryServiceImpl(gateway);
  });

  group('AuthenticationQueryServiceImpl.handleVerifyToken', () {
    test('should return the verification resource when the token is valid', () async {
      // Arrange
      when(() => gateway.verifyToken(any()))
          .thenAnswer((_) async => IamFixtures.validTokenVerification);

      // Act
      final result = await queryService.handleVerifyToken(IamFixtures.verifyTokenQuery());

      // Assert
      expect(result.isRight(), isTrue);
      final resource = expectRightValue(result);
      expect(resource.valid, isTrue);
      expect(resource.userId, IamFixtures.userId);
      expect(resource.expiresAt, '2026-01-01T00:00:00Z');
      verify(() => gateway.verifyToken(IamFixtures.accessToken)).called(1);
    });

    test('should return an invalid verification resource when the token is rejected', () async {
      // Arrange
      when(() => gateway.verifyToken(any()))
          .thenAnswer((_) async => IamFixtures.invalidTokenVerification);

      // Act
      final result = await queryService.handleVerifyToken(IamFixtures.verifyTokenQuery());

      // Assert
      expect(result.isRight(), isTrue);
      final resource = expectRightValue(result);
      expect(resource.valid, isFalse);
      expect(resource.userId, isNull);
      expect(resource.expiresAt, isNull);
    });

    test('should forward the raw access token of the query to the gateway', () async {
      // Arrange
      when(() => gateway.verifyToken(any()))
          .thenAnswer((_) async => IamFixtures.validTokenVerification);

      // Act
      await queryService.handleVerifyToken(IamFixtures.verifyTokenQuery());

      // Assert
      verify(() => gateway.verifyToken(IamFixtures.accessToken)).called(1);
    });

    test('should never trigger a remote mutation while verifying a token', () async {
      // Arrange
      when(() => gateway.verifyToken(any()))
          .thenAnswer((_) async => IamFixtures.validTokenVerification);

      // Act
      await queryService.handleVerifyToken(IamFixtures.verifyTokenQuery());

      // Assert
      verifyNever(() => gateway.signIn(any()));
      verifyNever(() => gateway.googleSignIn(any()));
      verifyNever(() => gateway.signOut(any()));
      verifyNever(() => gateway.refreshToken(any()));
      verifyNever(() => gateway.initiateRegistration(any()));
      verifyNever(() => gateway.confirmRegistration(any()));
    });

    test('should translate each HTTP status into its documented message', () async {
      // Arrange
      final expected = <int, String>{
        400: 'Invalid request.',
        401: 'Session expired. Please sign in again.',
        403: 'Access denied.',
        404: 'Not found.',
        500: 'Server error. Please try again later.',
        502: 'Server error. Please try again later.',
        503: 'Server error. Please try again later.',
        429: 'Network error. Please check your connection.',
      };

      for (final entry in expected.entries) {
        when(() => gateway.verifyToken(any())).thenThrow(
              DioException(
                requestOptions: RequestOptions(path: '/api/v1/auth/verify'),
                response: Response(
                  requestOptions: RequestOptions(path: '/api/v1/auth/verify'),
                  statusCode: entry.key,
                ),
              ),
            );

        // Act
        final result = await queryService.handleVerifyToken(IamFixtures.verifyTokenQuery());

        // Assert
        expect(result.isLeft(), isTrue, reason: 'status ${entry.key}');
        final failure = expectLeftFailure(result);
        expect(failure.message, entry.value, reason: 'status ${entry.key}');
      }
    });

    test('should report a network failure when the response has no status', () async {
      // Arrange
      when(() => gateway.verifyToken(any())).thenThrow(
        DioException.connectionTimeout(
          timeout: const Duration(seconds: 5),
          requestOptions: RequestOptions(path: '/api/v1/auth/verify'),
        ),
      );

      // Act
      final result = await queryService.handleVerifyToken(IamFixtures.verifyTokenQuery());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = expectLeftFailure(result);
      expect(failure.message, 'Network error. Please check your connection.');
    });

    test('should surface the message of a thrown Exception', () async {
      // Arrange
      when(() => gateway.verifyToken(any())).thenThrow(Exception('malformed payload'));

      // Act
      final result = await queryService.handleVerifyToken(IamFixtures.verifyTokenQuery());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = expectLeftFailure(result);
      expect(failure.message, 'malformed payload');
    });

    test('should fall back to a generic message when a non Exception is thrown', () async {
      // Arrange
      when(() => gateway.verifyToken(any())).thenThrow('boom');

      // Act
      final result = await queryService.handleVerifyToken(IamFixtures.verifyTokenQuery());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = expectLeftFailure(result);
      expect(failure.message, 'An unexpected error occurred');
    });
  });
}