import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/iam/application/internal/queryservices/authentication_query_service_impl.dart';
import 'package:mobile/iam/domain/model/queries/verify_token.query.dart';
import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';
import 'package:mobile/iam/infrastructure/api/gateways/authentication.gateway.dart';
import 'package:mobile/iam/interfaces/rest/resources/token_verification_resource.resource.dart';

class MockAuthenticationGateway extends Mock implements AuthenticationGateway {}

DioException createDioException({int? statusCode, String? message}) {
  return DioException(
    requestOptions: RequestOptions(path: '/verify'),
    response: statusCode != null
        ? Response(
            requestOptions: RequestOptions(path: '/verify'),
            statusCode: statusCode,
          )
        : null,
    message: message,
  );
}

void main() {
  late MockAuthenticationGateway mockGateway;
  late AuthenticationQueryServiceImpl queryService;

  setUp(() {
    mockGateway = MockAuthenticationGateway();
    queryService = AuthenticationQueryServiceImpl(mockGateway);
  });

  group('AuthenticationQueryServiceImpl - handleVerifyToken', () {
    test(
      'should return Right with TokenVerificationResource when gateway succeeds',
      () async {
        // Arrange
        const verificationResource = TokenVerificationResource(
          valid: true,
          userId: 'verified-user-123',
          expiresAt: '2026-12-31T23:59:59Z',
        );
        when(
          () => mockGateway.verifyToken('valid-token'),
        ).thenAnswer((_) async => verificationResource);

        final query = VerifyTokenQuery(accessToken: AccessToken('valid-token'));

        // Act
        final result = await queryService.handleVerifyToken(query);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Expected Right'), (resource) {
          expect(resource.valid, isTrue);
          expect(resource.userId, equals('verified-user-123'));
          expect(resource.expiresAt, equals('2026-12-31T23:59:59Z'));
        });
        verify(() => mockGateway.verifyToken('valid-token')).called(1);
      },
    );

    test(
      'should return Left with "Session expired. Please sign in again." when status is 401',
      () async {
        // Arrange
        when(
          () => mockGateway.verifyToken(any()),
        ).thenThrow(createDioException(statusCode: 401));

        final query = VerifyTokenQuery(
          accessToken: AccessToken('expired-token'),
        );

        // Act
        final result = await queryService.handleVerifyToken(query);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(
            failure.message,
            equals('Session expired. Please sign in again.'),
          ),
          (_) => fail('Expected Left'),
        );
      },
    );

    final statusCodesToMessages = {
      400: 'Invalid request.',
      403: 'Access denied.',
      404: 'Not found.',
      500: 'Server error. Please try again later.',
      502: 'Server error. Please try again later.',
      503: 'Server error. Please try again later.',
      999: 'Network error. Please check your connection.',
    };

    for (final entry in statusCodesToMessages.entries) {
      test(
        'should map DioException status ${entry.key} to "${entry.value}"',
        () async {
          // Arrange
          when(
            () => mockGateway.verifyToken(any()),
          ).thenThrow(createDioException(statusCode: entry.key));

          final query = VerifyTokenQuery(
            accessToken: AccessToken('some-token'),
          );

          // Act
          final result = await queryService.handleVerifyToken(query);

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure.message, equals(entry.value)),
            (_) => fail('Expected Left'),
          );
        },
      );
    }

    test('should map general Exception to its message', () async {
      // Arrange
      when(
        () => mockGateway.verifyToken(any()),
      ).thenThrow(Exception('Token decode failure'));

      final query = VerifyTokenQuery(accessToken: AccessToken('corrupt-token'));

      // Act
      final result = await queryService.handleVerifyToken(query);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('Token decode failure')),
        (_) => fail('Expected Left'),
      );
    });

    test(
      'should map non-exception error to default unexpected error message',
      () async {
        // Arrange
        when(() => mockGateway.verifyToken(any())).thenThrow(42);

        final query = VerifyTokenQuery(accessToken: AccessToken('some-token'));

        // Act
        final result = await queryService.handleVerifyToken(query);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) =>
              expect(failure.message, equals('An unexpected error occurred')),
          (_) => fail('Expected Left'),
        );
      },
    );
  });
}
