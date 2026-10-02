import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_page.resource.dart';
import 'package:mobile/notifications/interfaces/rest/resources/notification_response.resource.dart';

void main() {
  group('NotificationResponseResource', () {
    test('should deserialize from json when complete valid map is provided', () {
      // Arrange
      final json = {
        'id': 'notif-100',
        'userId': 'usr-200',
        'alertId': 'alt-300',
        'title': 'High PM2.5 Alert',
        'message': 'PM2.5 exceeded threshold',
        'sent': true,
        'errorMessage': null,
        'createdAt': '2026-10-02T10:00:00.000Z',
        'updatedAt': '2026-10-02T10:01:00.000Z',
      };

      // Act
      final resource = NotificationResponseResource.fromJson(json);

      // Assert
      expect(resource.id, equals('notif-100'));
      expect(resource.userId, equals('usr-200'));
      expect(resource.alertId, equals('alt-300'));
      expect(resource.title, equals('High PM2.5 Alert'));
      expect(resource.message, equals('PM2.5 exceeded threshold'));
      expect(resource.sent, isTrue);
      expect(resource.errorMessage, isNull);
      expect(resource.createdAt, equals('2026-10-02T10:00:00.000Z'));
      expect(resource.updatedAt, equals('2026-10-02T10:01:00.000Z'));
    });

    test('should handle null and missing optional fields with default fallback values', () {
      // Arrange
      final json = <String, dynamic>{
        'id': 12345,
        'userId': 67890,
        'title': 'System maintenance',
        'message': 'Scheduled downtime',
      };

      // Act
      final resource = NotificationResponseResource.fromJson(json);

      // Assert
      expect(resource.id, equals('12345'));
      expect(resource.userId, equals('67890'));
      expect(resource.alertId, isNull);
      expect(resource.sent, isFalse);
      expect(resource.errorMessage, isNull);
      expect(resource.createdAt, isEmpty);
      expect(resource.updatedAt, isEmpty);
    });

    test('should parse sent boolean correctly when sent is true or false', () {
      // Arrange & Act
      final sentResource = NotificationResponseResource.fromJson({'sent': true});
      final unsentResource = NotificationResponseResource.fromJson({'sent': false});
      final nullSentResource = NotificationResponseResource.fromJson({});

      // Assert
      expect(sentResource.sent, isTrue);
      expect(unsentResource.sent, isFalse);
      expect(nullSentResource.sent, isFalse);
    });

    test('should serialize to json when calling toJson()', () {
      // Arrange
      final resource = NotificationResponseResource(
        id: 'notif-101',
        userId: 'usr-101',
        alertId: 'alt-101',
        title: 'Device Offline',
        message: 'Device has lost connectivity',
        sent: false,
        errorMessage: 'Connection timeout',
        createdAt: '2026-10-02T12:00:00Z',
        updatedAt: '2026-10-02T12:01:00Z',
      );

      // Act
      final json = resource.toJson();

      // Assert
      expect(json, equals({
        'id': 'notif-101',
        'userId': 'usr-101',
        'alertId': 'alt-101',
        'title': 'Device Offline',
        'message': 'Device has lost connectivity',
        'sent': false,
        'errorMessage': 'Connection timeout',
        'createdAt': '2026-10-02T12:00:00Z',
        'updatedAt': '2026-10-02T12:01:00Z',
      }));
    });
  });

  group('NotificationPageResource', () {
    test('should deserialize from json when complete valid map is provided', () {
      // Arrange
      final json = {
        'content': [
          {
            'id': 'n-1',
            'userId': 'u-1',
            'title': 'T1',
            'message': 'M1',
            'sent': true,
            'createdAt': '2026-10-01T00:00:00Z',
            'updatedAt': '2026-10-01T00:00:00Z',
          },
          {
            'id': 'n-2',
            'userId': 'u-2',
            'title': 'T2',
            'message': 'M2',
            'sent': false,
            'createdAt': '2026-10-01T01:00:00Z',
            'updatedAt': '2026-10-01T01:00:00Z',
          },
        ],
        'totalElements': 50,
        'totalPages': 5,
        'size': 10,
        'number': 2,
      };

      // Act
      final page = NotificationPageResource.fromJson(json);

      // Assert
      expect(page.content.length, equals(2));
      expect(page.content.first.id, equals('n-1'));
      expect(page.content.last.id, equals('n-2'));
      expect(page.totalElements, equals(50));
      expect(page.totalPages, equals(5));
      expect(page.size, equals(10));
      expect(page.number, equals(2));
    });

    test('should handle empty content list or non-list content gracefully', () {
      // Arrange
      final emptyJson = {'content': <dynamic>[]};
      final nonListJson = {'content': 'invalid'};
      final nullJson = <String, dynamic>{};

      // Act
      final emptyPage = NotificationPageResource.fromJson(emptyJson);
      final nonListPage = NotificationPageResource.fromJson(nonListJson);
      final nullPage = NotificationPageResource.fromJson(nullJson);

      // Assert
      expect(emptyPage.content, isEmpty);
      expect(nonListPage.content, isEmpty);
      expect(nullPage.content, isEmpty);
      expect(nullPage.totalElements, equals(0));
      expect(nullPage.totalPages, equals(0));
      expect(nullPage.size, equals(0));
      expect(nullPage.number, equals(0));
    });

    test('should serialize to json when calling toJson()', () {
      // Arrange
      final item = NotificationResponseResource(
        id: 'n-10',
        userId: 'u-10',
        title: 'Title 10',
        message: 'Message 10',
        sent: true,
        createdAt: '2026-10-02T12:00:00Z',
        updatedAt: '2026-10-02T12:00:00Z',
      );
      final page = NotificationPageResource(
        content: [item],
        totalElements: 1,
        totalPages: 1,
        size: 20,
        number: 0,
      );

      // Act
      final json = page.toJson();

      // Assert
      expect(json['totalElements'], equals(1));
      expect(json['totalPages'], equals(1));
      expect(json['size'], equals(20));
      expect(json['number'], equals(0));
      expect((json['content'] as List).length, equals(1));
      expect((json['content'] as List).first['id'], equals('n-10'));
    });
  });
}
