import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/notifications/application/internal/queryservices/notifications_query_service_impl.dart';
import 'package:mobile/notifications/domain/model/queries/get_notifications.query.dart';
import 'package:mobile/notifications/domain/model/valueobjects/notification_page.valueobject.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_page.resource.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/notifications_fixtures.dart';

void main() {
  late MockNotificationsGateway gateway;
  late NotificationsQueryServiceImpl queryService;

  setUpAll(() {
    registerFallbackValue(GetNotificationsQuery());
  });

  setUp(() {
    gateway = MockNotificationsGateway();
    queryService = NotificationsQueryServiceImpl(gateway);
  });

  /// Builds the dio error the backend failure paths produce.
  DioException dioError(
    Object? data, {
    int? statusCode,
    String? message,
    DioExceptionType type = DioExceptionType.badResponse,
  }) {
    final options = RequestOptions(path: '/api/v1/notifications/push');
    return DioException(
      requestOptions: options,
      type: type,
      message: message,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: options,
              statusCode: statusCode,
              data: data,
            ),
    );
  }

  void stubResource(NotificationPageResource resource) {
    when(
      () => gateway.getNotifications(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => resource);
  }

  /// Fails the test when [result] is not the expected [Either] variant.
  Never unexpected(String variant) =>
      throw StateError('expected a $variant but got the other variant');

  /// Reads the [Failure] payload of a left result.
  Failure failureOf(Either<Failure, NotificationPage> result) {
    return result.fold<Failure>(
      (failure) => failure,
      (_) => unexpected('Left'),
    );
  }

  /// Reads the [NotificationPage] payload of a right result.
  NotificationPage pageOf(Either<Failure, NotificationPage> result) {
    return result.fold<NotificationPage>(
      (_) => unexpected('Right'),
      (page) => page,
    );
  }

  group('NotificationsQueryServiceImpl.handleGetNotifications on success', () {
    test('should return a right holding the mapped domain page', () async {
      // Arrange
      stubResource(
        notificationPageResourceFromJson(<String, Object?>{
          'content': <Object?>[
            <String, Object?>{
              ...notificationJson,
              'id': 'notification-1',
              'title': 'High temperature',
            },
            <String, Object?>{
              ...notificationJson,
              'id': 'notification-2',
              'title': 'Smoke detected',
              'sent': false,
              'errorMessage': 'Push token expired',
            },
          ],
          'totalElements': 2,
          'totalPages': 1,
          'size': 20,
          'number': 0,
        }),
      );
      final query = GetNotificationsQuery(page: 0, size: 20);

      // Act
      final result =
          await queryService.handleGetNotifications(query);

      // Assert
      expect(result.isRight(), isTrue);
      final page = pageOf(result);
      expect(page.content, hasLength(2));
      expect(page.content.first.id.value, 'notification-1');
      expect(page.content.first.title, 'High temperature');
      expect(page.content.first.createdAt, DateTime.utc(2024, 5, 1, 10, 30));
      expect(page.content.last.id.value, 'notification-2');
      expect(page.content.last.sent, isFalse);
      expect(page.content.last.errorMessage, 'Push token expired');
      expect(page.totalElements, 2);
      expect(page.totalPages, 1);
      expect(page.size, 20);
      expect(page.number, 0);
    });

    test('should forward the requested page and size to the gateway', () async {
      // Arrange
      stubResource(
        notificationPageResourceFromJson(emptyNotificationsPageJson),
      );
      final query = GetNotificationsQuery(page: 3, size: 50);

      // Act
      await queryService.handleGetNotifications(query);

      // Assert: the boundary arguments and the call count come from the very
      // same verify.
      final captured = verify(
        () => gateway.getNotifications(
          page: captureAny(named: 'page'),
          size: captureAny(named: 'size'),
        ),
      ).captured;
      expect(captured, <Object>[3, 50]);
    });

    test('should forward the default page and size when the query is not '
        'customised', () async {
      // Arrange
      stubResource(
        notificationPageResourceFromJson(emptyNotificationsPageJson),
      );

      // Act
      await queryService.handleGetNotifications(GetNotificationsQuery());

      // Assert
      final captured = verify(
        () => gateway.getNotifications(
          page: captureAny(named: 'page'),
          size: captureAny(named: 'size'),
        ),
      ).captured;
      expect(captured, <Object>[0, 20]);
    });

    test('should read exactly one page from the gateway', () async {
      // Arrange
      stubResource(
        notificationPageResourceFromJson(emptyNotificationsPageJson),
      );

      // Act
      await queryService.handleGetNotifications(GetNotificationsQuery());

      // Assert: a read service never reaches a write operation.
      verify(
        () => gateway.getNotifications(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).called(1);
    });

    test('should return a right holding an empty page when the backend has no '
        'notifications', () async {
      // Arrange
      stubResource(
        notificationPageResourceFromJson(emptyNotificationsPageJson),
      );

      // Act
      final result = await queryService.handleGetNotifications(
        GetNotificationsQuery(),
      );

      // Assert
      expect(result.isRight(), isTrue);
      final page = pageOf(result);
      expect(page.content, isEmpty);
      expect(page.totalElements, 0);
      expect(page.totalPages, 0);
    });

    test('should return a right holding an empty page when the backend omits '
        'the content key', () async {
      // Arrange
      stubResource(
        notificationPageResourceFromJson(<String, Object?>{'totalElements': 0}),
      );

      // Act
      final result = await queryService.handleGetNotifications(
        GetNotificationsQuery(),
      );

      // Assert
      expect(result.isRight(), isTrue);
      final page = pageOf(result);
      expect(page.content, isEmpty);
    });
  });

  group('NotificationsQueryServiceImpl.handleGetNotifications on dio failure',
      () {
    const Map<String, int> statusCases = <String, int>{
      '400': 400,
      '401': 401,
      '403': 403,
      '404': 404,
      '409': 409,
      '500': 500,
      '503': 503,
    };

    statusCases.forEach((String label, int statusCode) {
      test('should surface the backend message of a $label answer', () async {
        // Arrange
        when(
          () => gateway.getNotifications(
            page: any(named: 'page'),
            size: any(named: 'size'),
          ),
        ).thenAnswer(
          (_) async => throw dioError(
            <String, dynamic>{'message': 'Backend rejected the request'},
            statusCode: statusCode,
          ),
        );

        // Act
        final result = await queryService.handleGetNotifications(
          GetNotificationsQuery(),
        );

        // Assert
        expect(result.isLeft(), isTrue);
        final failure = failureOf(result);
        expect(failure.message, 'Backend rejected the request');
        expect(failure.statusCode, statusCode);
      });
    });

    test('should report a generic message when the backend answer carries no '
        'message key', () async {
      // Arrange
      when(
        () => gateway.getNotifications(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => throw dioError(
          <String, dynamic>{'error': 'nope'},
          statusCode: 404,
        ),
      );

      // Act
      final result =
          await queryService.handleGetNotifications(GetNotificationsQuery());

      // Assert: a hand raised `DioException` without a message leaves
      // `error.message` null, so the service falls back to its generic text.
      expect(result.isLeft(), isTrue);
      final failure = failureOf(result);
      expect(failure.message, 'An unexpected error occurred');
      expect(failure.statusCode, 404);
    });

    test('should stringify a non textual backend message', () async {
      // Arrange
      when(
        () => gateway.getNotifications(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => throw dioError(
          <String, dynamic>{'message': 42},
          statusCode: 400,
        ),
      );

      // Act
      final result =
          await queryService.handleGetNotifications(GetNotificationsQuery());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = failureOf(result);
      expect(failure.message, '42');
      expect(failure.statusCode, 400);
    });

    test('should report no status code when the transport never answered',
        () async {
      // Arrange
      when(
        () => gateway.getNotifications(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => throw dioError(
          null,
          message: 'Connection timeout of 5000 milliseconds exceeded',
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // Act
      final result =
          await queryService.handleGetNotifications(GetNotificationsQuery());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = failureOf(result);
      expect(
        failure.message,
        'Connection timeout of 5000 milliseconds exceeded',
      );
      expect(failure.statusCode, isNull);
    });

    test('should report a generic failure when the dio error carries neither a '
        'backend message nor a transport message', () async {
      // Arrange
      when(
        () => gateway.getNotifications(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => throw dioError(null, statusCode: 500));

      // Act
      final result =
          await queryService.handleGetNotifications(GetNotificationsQuery());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = failureOf(result);
      expect(failure.message, 'An unexpected error occurred');
      expect(failure.statusCode, 500);
    });
  });

  group('NotificationsQueryServiceImpl.handleGetNotifications on unexpected '
      'error', () {
    test('should translate a non dio error into a generic failure', () async {
      // Arrange
      when(
        () => gateway.getNotifications(
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => throw StateError('gateway exploded'),
      );

      // Act
      final result =
          await queryService.handleGetNotifications(GetNotificationsQuery());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = failureOf(result);
      expect(failure.message, 'An unexpected error occurred');
      expect(failure.statusCode, isNull);
    });

    test('should translate the mapping error of a blank wire identifier into a '
        'generic failure instead of throwing', () async {
      // Arrange
      stubResource(
        notificationPageResourceFromJson(<String, Object?>{
          'content': <Object?>[
            <String, Object?>{'id': ''},
          ],
        }),
      );

      // Act
      final result =
          await queryService.handleGetNotifications(GetNotificationsQuery());

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = failureOf(result);
      expect(failure.message, 'An unexpected error occurred');
      expect(failure.statusCode, isNull);
    });
  });

  group('NotificationsQueryServiceImpl invalid input', () {
    test('should never reach the gateway when the query is rejected at '
        'construction', () async {
      // Arrange
      stubResource(
        notificationPageResourceFromJson(emptyNotificationsPageJson),
      );

      // Act
      expect(
        () => GetNotificationsQuery(page: -1, size: 20),
        throwsArgumentError,
      );

      // Assert: the read model is the validation boundary, so an invalid page
      // can never be handed to the service.
      verifyZeroInteractions(gateway);
    });

    test('should never reach the gateway when the page size is out of range',
        () async {
      // Arrange
      stubResource(
        notificationPageResourceFromJson(emptyNotificationsPageJson),
      );

      // Act
      expect(() => GetNotificationsQuery(size: 0), throwsArgumentError);
      expect(() => GetNotificationsQuery(size: 101), throwsArgumentError);

      // Assert
      verifyZeroInteractions(gateway);
    });
  });
}