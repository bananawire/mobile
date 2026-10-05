import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/notifications_fixtures.dart';

void main() {
  group('NotificationResponseResource.fromJson', () {
    test('should read every field of a well formed payload', () {
      // Arrange
      final json = notificationResourceFromJson(notificationJson);

      // Assert
      expect(json.id, 'notification-1');
      expect(json.userId, 'user-1');
      expect(json.alertId, 'alert-1');
      expect(json.title, 'High temperature');
      expect(json.message, 'The kitchen sensor reported 41 degrees');
      expect(json.sent, isTrue);
      expect(json.errorMessage, isNull);
      expect(json.createdAt, '2024-05-01T10:30:00Z');
      expect(json.updatedAt, '2024-05-01T10:31:00Z');
    });

    test('should keep the delivery error of an undelivered notification', () {
      // Arrange
      final json = notificationResourceFromJson(<String, Object?>{
        ...notificationJson,
        'sent': false,
        'errorMessage': 'Push token expired',
      });

      // Assert
      expect(json.sent, isFalse);
      expect(json.errorMessage, 'Push token expired');
    });

    test('should default every missing text field to an empty string', () {
      // Arrange / Act
      final json = notificationResourceFromJson(const <String, Object?>{});

      // Assert
      expect(json.id, isEmpty);
      expect(json.userId, isEmpty);
      expect(json.title, isEmpty);
      expect(json.message, isEmpty);
      expect(json.createdAt, isEmpty);
      expect(json.updatedAt, isEmpty);
    });

    test('should default the optional fields to null when they are missing',
        () {
      // Arrange / Act
      final json = notificationResourceFromJson(const <String, Object?>{
        'id': 'notification-1',
      });

      // Assert
      expect(json.alertId, isNull);
      expect(json.errorMessage, isNull);
    });

    test('should read an explicit null optional field as null', () {
      // Arrange / Act
      final json = notificationResourceFromJson(<String, Object?>{
        'id': 'notification-1',
        'alertId': null,
        'errorMessage': null,
      });

      // Assert
      expect(json.alertId, isNull);
      expect(json.errorMessage, isNull);
    });

    test('should coerce a non string identifier to its string form', () {
      // Arrange / Act
      final json = notificationResourceFromJson(<String, Object?>{
        'id': 42,
        'userId': 9001,
      });

      // Assert
      expect(json.id, '42');
      expect(json.userId, '9001');
    });

    test('should coerce non string optional fields to their string form', () {
      // Arrange / Act
      final json = notificationResourceFromJson(<String, Object?>{
        'alertId': 7,
        'errorMessage': 500,
      });

      // Assert
      expect(json.alertId, '7');
      expect(json.errorMessage, '500');
    });

    test('should stringify a numeric timestamp instead of parsing it', () {
      // Arrange / Act
      final json = notificationResourceFromJson(<String, Object?>{
        'createdAt': 1714557000000,
        'updatedAt': 1714557060000,
      });

      // Assert: the resource keeps the raw text, parsing belongs to the
      // transform.
      expect(json.createdAt, '1714557000000');
      expect(json.updatedAt, '1714557060000');
    });

    test('should keep an empty delivery error as an empty string', () {
      // Arrange / Act
      final json = notificationResourceFromJson(<String, Object?>{
        'errorMessage': '',
      });

      // Assert
      expect(json.errorMessage, isEmpty);
    });

    test('should report a sent flag only when the wire value is the boolean '
        'true', () {
      // Arrange
      final Map<String, Object?> truthyButNotBool = <String, Object?>{
        'sent': 'true',
      };
      final Map<String, Object?> numeric = <String, Object?>{'sent': 1};

      // Act
      final fromString = notificationResourceFromJson(truthyButNotBool);
      final fromNumber = notificationResourceFromJson(numeric);
      final fromMissing =
          notificationResourceFromJson(const <String, Object?>{});

      // Assert
      expect(fromString.sent, isFalse);
      expect(fromNumber.sent, isFalse);
      expect(fromMissing.sent, isFalse);
    });

    test('should report a sent flag of false when the wire value is false', () {
      // Arrange / Act
      final json = notificationResourceFromJson(<String, Object?>{
        'sent': false,
      });

      // Assert
      expect(json.sent, isFalse);
    });

    test('should ignore unknown extra keys coming from the backend', () {
      // Arrange / Act
      final json = notificationResourceFromJson(<String, Object?>{
        ...notificationJson,
        'unknownField': 'ignored',
      });

      // Assert
      expect(json.id, 'notification-1');
      expect(json.title, 'High temperature');
    });
  });
}