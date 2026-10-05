import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/queries/get_dashboard_metrics.query.dart';
import 'package:mobile/analytics/domain/model/queries/get_trends.query.dart';

void main() {
  group('GetDashboardMetricsQuery', () {
    test('should expose the device id and period of a live request', () {
      // Arrange / Act
      const query = GetDashboardMetricsQuery(
        deviceId: 'device-1',
        period: 'LIVE',
      );

      // Assert
      expect(query.deviceId, 'device-1');
      expect(query.period, 'LIVE');
      expect(query.startDate, isNull);
      expect(query.endDate, isNull);
    });

    test('should keep the explicit historical range it was built with', () {
      // Arrange
      const start = '2024-05-01T00:00:00Z';
      const end = '2024-05-02T00:00:00Z';

      // Act
      const query = GetDashboardMetricsQuery(
        deviceId: 'device-1',
        period: 'DAY',
        startDate: start,
        endDate: end,
      );

      // Assert
      expect(query.period, 'DAY');
      expect(query.startDate, start);
      expect(query.endDate, end);
    });

    test('should default the period to null so the gateway can pick the live '
        'endpoint', () {
      // Arrange / Act
      const query = GetDashboardMetricsQuery(deviceId: 'device-1');

      // Assert
      expect(query.period, isNull);
    });
  });

  group('GetTrendsQuery', () {
    test('should expose the device id and trend period of the request', () {
      // Arrange / Act
      const query = GetTrendsQuery(deviceId: 'device-1', period: 'DAY');

      // Assert
      expect(query.deviceId, 'device-1');
      expect(query.period, 'DAY');
      expect(query.startDate, isNull);
      expect(query.endDate, isNull);
    });

    test('should keep a custom date range for future re-enable of the '
        'historical endpoints', () {
      // Arrange / Act
      const query = GetTrendsQuery(
        deviceId: 'device-1',
        startDate: '2024-05-01T00:00:00Z',
        endDate: '2024-05-08T00:00:00Z',
      );

      // Assert
      expect(query.period, isNull);
      expect(query.startDate, '2024-05-01T00:00:00Z');
      expect(query.endDate, '2024-05-08T00:00:00Z');
    });
  });
}