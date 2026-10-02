import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_page.resource.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_response.resource.dart';
import 'package:mobile/notifications/interfaces/rest/transform/notifications_transform.dart';

void main() {
  group('notificationResponseResourceToDomain', () {
    test(
      'should map NotificationResponseResource to NotificationLog when all fields are valid',
      () {
        // Arrange
        final resource = NotificationResponseResource(
          id: 'notif-123',
          userId: 'user-456',
          alertId: 'alert-789',
          title: 'Sensor Offline',
          message: 'Living room sensor is not responding',
          sent: true,
          errorMessage: null,
          createdAt: '2026-10-02T08:30:00.000Z',
          updatedAt: '2026-10-02T08:31:00.000Z',
        );

        // Act
        final domain = notificationResponseResourceToDomain(resource);

        // Assert
        expect(domain.id.value, equals('notif-123'));
        expect(domain.userId, equals('user-456'));
        expect(domain.alertId, equals('alert-789'));
        expect(domain.title, equals('Sensor Offline'));
        expect(domain.message, equals('Living room sensor is not responding'));
        expect(domain.sent, isTrue);
        expect(domain.errorMessage, isNull);
        expect(
          domain.createdAt,
          equals(DateTime.parse('2026-10-02T08:30:00.000Z')),
        );
        expect(
          domain.updatedAt,
          equals(DateTime.parse('2026-10-02T08:31:00.000Z')),
        );
      },
    );

    test(
      'should fallback to current time when createdAt and updatedAt are unparseable',
      () {
        // Arrange
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final resource = NotificationResponseResource(
          id: 'notif-999',
          userId: 'user-999',
          title: 'Malformed Date',
          message: 'Testing fallback',
          sent: false,
          errorMessage: 'Some error',
          createdAt: 'invalid-date',
          updatedAt: 'also-invalid',
        );

        // Act
        final domain = notificationResponseResourceToDomain(resource);
        final after = DateTime.now().add(const Duration(seconds: 1));

        // Assert
        expect(domain.id.value, equals('notif-999'));
        expect(domain.createdAt.isAfter(before), isTrue);
        expect(domain.createdAt.isBefore(after), isTrue);
        expect(domain.updatedAt.isAfter(before), isTrue);
        expect(domain.updatedAt.isBefore(after), isTrue);
      },
    );

    test(
      'should map optional fields correctly when alertId and errorMessage are null',
      () {
        // Arrange
        final resource = NotificationResponseResource(
          id: 'notif-321',
          userId: 'user-321',
          alertId: null,
          title: 'Welcome',
          message: 'Welcome to Clair',
          sent: true,
          errorMessage: null,
          createdAt: '2026-10-02T00:00:00Z',
          updatedAt: '2026-10-02T00:00:00Z',
        );

        // Act
        final domain = notificationResponseResourceToDomain(resource);

        // Assert
        expect(domain.alertId, isNull);
        expect(domain.errorMessage, isNull);
      },
    );
  });

  group('notificationPageResourceToDomain', () {
    test(
      'should map NotificationPageResource to NotificationPage with transformed content',
      () {
        // Arrange
        final item1 = NotificationResponseResource(
          id: 'n-1',
          userId: 'u-1',
          title: 'Title 1',
          message: 'Message 1',
          sent: true,
          createdAt: '2026-10-01T10:00:00Z',
          updatedAt: '2026-10-01T10:00:00Z',
        );
        final item2 = NotificationResponseResource(
          id: 'n-2',
          userId: 'u-2',
          title: 'Title 2',
          message: 'Message 2',
          sent: false,
          errorMessage: 'Failed to deliver',
          createdAt: '2026-10-01T11:00:00Z',
          updatedAt: '2026-10-01T11:00:00Z',
        );
        final pageResource = NotificationPageResource(
          content: [item1, item2],
          totalElements: 42,
          totalPages: 5,
          size: 10,
          number: 1,
        );

        // Act
        final domainPage = notificationPageResourceToDomain(pageResource);

        // Assert
        expect(domainPage.content.length, equals(2));
        expect(domainPage.content[0].id.value, equals('n-1'));
        expect(domainPage.content[0].title, equals('Title 1'));
        expect(domainPage.content[1].id.value, equals('n-2'));
        expect(domainPage.content[1].errorMessage, equals('Failed to deliver'));
        expect(domainPage.totalElements, equals(42));
        expect(domainPage.totalPages, equals(5));
        expect(domainPage.size, equals(10));
        expect(domainPage.number, equals(1));
      },
    );

    test('should handle empty content list correctly', () {
      // Arrange
      final pageResource = NotificationPageResource(
        content: [],
        totalElements: 0,
        totalPages: 0,
        size: 20,
        number: 0,
      );

      // Act
      final domainPage = notificationPageResourceToDomain(pageResource);

      // Assert
      expect(domainPage.content, isEmpty);
      expect(domainPage.totalElements, equals(0));
      expect(domainPage.totalPages, equals(0));
      expect(domainPage.size, equals(20));
      expect(domainPage.number, equals(0));
    });
  });
}
