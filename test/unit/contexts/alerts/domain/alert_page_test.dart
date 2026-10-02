import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_id.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_page.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/metric_type.valueobject.dart';

void main() {
  group('AlertPage ValueObject', () {
    Alert createDummyAlert(String id) {
      return Alert(
        id: AlertId(id),
        deviceId: 'device-1',
        metric: MetricType.co2,
        metricLabel: 'CO2',
        metricUnit: 'ppm',
        thresholdValue: 1000.0,
        actualValue: 1250.0,
        message: 'High CO2 level detected',
        status: AlertStatus.active,
        severity: AlertSeverity.critical,
        occurredAt: '2026-10-02T10:00:00Z',
        createdAt: '2026-10-02T10:00:00Z',
      );
    }

    test(
      'should construct AlertPage with all required pagination properties',
      () {
        // Arrange
        final alert1 = createDummyAlert('alert-1');
        final alert2 = createDummyAlert('alert-2');

        // Act
        final page = AlertPage(
          content: [alert1, alert2],
          totalElements: 50,
          totalPages: 5,
          size: 10,
          number: 2,
        );

        // Assert
        expect(page.content.length, equals(2));
        expect(page.content.first.id.value, equals('alert-1'));
        expect(page.totalElements, equals(50));
        expect(page.totalPages, equals(5));
        expect(page.size, equals(10));
        expect(page.number, equals(2));
        expect(page.page, equals(2));
      },
    );

    test('should construct empty AlertPage when content is empty', () {
      // Arrange & Act
      const page = AlertPage(
        content: [],
        totalElements: 0,
        totalPages: 0,
        size: 20,
        number: 0,
      );

      // Assert
      expect(page.content, isEmpty);
      expect(page.totalElements, equals(0));
      expect(page.totalPages, equals(0));
      expect(page.size, equals(20));
      expect(page.number, equals(0));
      expect(page.page, equals(0));
    });
  });
}
