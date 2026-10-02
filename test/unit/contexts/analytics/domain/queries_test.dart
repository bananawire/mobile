import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/queries/get_dashboard_metrics.query.dart';
import 'package:mobile/analytics/domain/model/queries/get_trends.query.dart';

void main() {
  group('GetDashboardMetricsQuery', () {
    test('should construct query when only required deviceId is provided', () {
      // Arrange & Act
      const query = GetDashboardMetricsQuery(deviceId: 'dev-001');

      // Assert
      expect(query.deviceId, equals('dev-001'));
      expect(query.period, isNull);
      expect(query.startDate, isNull);
      expect(query.endDate, isNull);
    });

    test('should construct query when all optional fields are provided', () {
      // Arrange & Act
      const query = GetDashboardMetricsQuery(
        deviceId: 'dev-002',
        period: 'DAY',
        startDate: '2026-10-01T00:00:00Z',
        endDate: '2026-10-02T00:00:00Z',
      );

      // Assert
      expect(query.deviceId, equals('dev-002'));
      expect(query.period, equals('DAY'));
      expect(query.startDate, equals('2026-10-01T00:00:00Z'));
      expect(query.endDate, equals('2026-10-02T00:00:00Z'));
    });
  });

  group('GetTrendsQuery', () {
    test('should construct query when only required deviceId is provided', () {
      // Arrange & Act
      const query = GetTrendsQuery(deviceId: 'dev-100');

      // Assert
      expect(query.deviceId, equals('dev-100'));
      expect(query.period, isNull);
      expect(query.startDate, isNull);
      expect(query.endDate, isNull);
    });

    test('should construct query when all optional fields are provided', () {
      // Arrange & Act
      const query = GetTrendsQuery(
        deviceId: 'dev-200',
        period: 'WEEK',
        startDate: '2026-09-25T00:00:00Z',
        endDate: '2026-10-02T00:00:00Z',
      );

      // Assert
      expect(query.deviceId, equals('dev-200'));
      expect(query.period, equals('WEEK'));
      expect(query.startDate, equals('2026-09-25T00:00:00Z'));
      expect(query.endDate, equals('2026-10-02T00:00:00Z'));
    });
  });
}
