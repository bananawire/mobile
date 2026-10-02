import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/notifications/application/internal/queryservices/notifications_query_service_impl.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/infrastructure/api/gateways/notifications.gateway.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_page.resource.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_response.resource.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsGateway extends Mock implements NotificationsGateway {}

void main() {
  late MockNotificationsGateway mockGateway;
  late NotificationsQueryServiceImpl service;

  setUp(() {
    mockGateway = MockNotificationsGateway();
    service = NotificationsQueryServiceImpl(mockGateway);
  });

  group('NotificationsQueryServiceImpl', () {
    test(
      'should return Right(NotificationPage) when gateway successfully returns NotificationPageResource',
      () async {
        // Arrange
        final fakeResource = NotificationPageResource(
          content: [
            NotificationResponseResource(
              id: 'n-1',
              userId: 'u-1',
              title: 'Critical Temp',
              message: 'Temperature exceeds safe threshold',
              sent: true,
              createdAt: '2026-10-02T12:00:00Z',
              updatedAt: '2026-10-02T12:00:00Z',
            ),
          ],
          totalElements: 1,
          totalPages: 1,
          size: 20,
          number: 0,
        );

        when(
          () => mockGateway.getNotifications(page: 0, size: 20),
        ).thenAnswer((_) async => fakeResource);

        // Act
        final result = await service.handleGetNotifications(
          GetNotificationsQuery(page: 0, size: 20),
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('Expected Right, got Left: $failure'), (
          page,
        ) {
          expect(page, isA<NotificationPage>());
          expect(page.content.length, equals(1));
          expect(page.content.first.id.value, equals('n-1'));
          expect(page.content.first.title, equals('Critical Temp'));
          expect(page.totalElements, equals(1));
          expect(page.totalPages, equals(1));
        });
        verify(() => mockGateway.getNotifications(page: 0, size: 20)).called(1);
      },
    );

    test('should pass query pagination parameters to gateway', () async {
      // Arrange
      final emptyResource = NotificationPageResource(
        content: [],
        totalElements: 0,
        totalPages: 0,
        size: 15,
        number: 2,
      );

      when(
        () => mockGateway.getNotifications(page: 2, size: 15),
      ).thenAnswer((_) async => emptyResource);

      // Act
      final result = await service.handleGetNotifications(
        GetNotificationsQuery(page: 2, size: 15),
      );

      // Assert
      expect(result.isRight(), isTrue);
      verify(() => mockGateway.getNotifications(page: 2, size: 15)).called(1);
    });

    test(
      'should return Left(Failure) with server message when DioException contains server response data',
      () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/notifications'),
          response: Response(
            requestOptions: RequestOptions(path: '/notifications'),
            statusCode: 403,
            data: {'message': 'Forbidden access'},
          ),
        );

        when(
          () => mockGateway.getNotifications(page: 0, size: 20),
        ).thenThrow(dioException);

        // Act
        final result = await service.handleGetNotifications(
          GetNotificationsQuery(page: 0, size: 20),
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<Failure>());
          expect(failure.message, equals('Forbidden access'));
          expect(failure.statusCode, equals(403));
        }, (_) => fail('Expected Left, got Right'));
      },
    );

    test(
      'should return Left(Failure) with dio message when DioException response has no custom message',
      () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/notifications'),
          response: Response(
            requestOptions: RequestOptions(path: '/notifications'),
            statusCode: 502,
            data: null,
          ),
          message: 'Bad Gateway error',
        );

        when(
          () => mockGateway.getNotifications(page: 0, size: 20),
        ).thenThrow(dioException);

        // Act
        final result = await service.handleGetNotifications(
          GetNotificationsQuery(page: 0, size: 20),
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<Failure>());
          expect(failure.message, equals('Bad Gateway error'));
          expect(failure.statusCode, equals(502));
        }, (_) => fail('Expected Left, got Right'));
      },
    );

    test(
      'should return Left(Failure) with unexpected error message when a generic exception is thrown',
      () async {
        // Arrange
        when(
          () => mockGateway.getNotifications(
            page: any(named: 'page'),
            size: any(named: 'size'),
          ),
        ).thenThrow(Exception('Unknown system crash'));

        // Act
        final result = await service.handleGetNotifications(
          GetNotificationsQuery(page: 0, size: 20),
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<Failure>());
          expect(failure.message, equals('An unexpected error occurred'));
          expect(failure.statusCode, isNull);
        }, (_) => fail('Expected Left, got Right'));
      },
    );
  });
}
