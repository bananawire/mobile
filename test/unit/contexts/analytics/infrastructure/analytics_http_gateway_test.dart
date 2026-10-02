import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/analytics/infrastructure/api/gateways/analytics_http.gateway.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';

import '../../../../support/fake_http_client_adapter.dart';

class MockTokenLocalStorage extends Mock implements TokenLocalStorage {}

void main() {
  late Dio dio;
  late MockTokenLocalStorage mockTokenStorage;
  late AnalyticsHttpGateway gateway;
  late RequestOptions capturedOptions;

  final sampleMetricsJson = {
    'aqiValue': 35.0,
    'aqiCategory': 'Good',
    'averageCo2': 480.0,
    'averagePm2_5': 9.0,
    'averageTemperature': 21.0,
    'averageHumidity': 45.0,
    'co2DeltaPercentage': 2.1,
    'pm2_5DeltaPercentage': -1.2,
    'temperatureDeltaPercentage': 0.5,
    'humidityDeltaPercentage': 1.0,
    'calculatedAt': '2026-10-02T12:00:00Z',
  };

  final sampleTrendsJson = {
    'dataPoints': [
      {
        'timestamp': '2026-10-02T10:00:00Z',
        'aqiValue': 30.0,
        'co2': 460.0,
        'pm2_5': 8.0,
        'temperature': 20.5,
        'humidity': 44.0,
      },
    ],
  };

  setUp(() {
    mockTokenStorage = MockTokenLocalStorage();
    dio = Dio(BaseOptions(baseUrl: 'https://api.test.com'));
  });

  group('AnalyticsHttpGateway - getDashboardMetrics', () {
    test('should request live endpoint when period is null', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse(sampleMetricsJson);
      });
      gateway = AnalyticsHttpGateway(dio, mockTokenStorage);

      // Act
      final result = await gateway.getDashboardMetrics(deviceId: 'device-001');

      // Assert
      expect(capturedOptions.method, equals('GET'));
      expect(capturedOptions.path, equals('/api/v1/analytics/devices/device-001/live'));
      expect(capturedOptions.queryParameters, isEmpty);
      expect(result.aqiValue, equals(35.0));
      expect(result.aqiCategory, equals('Good'));
    });

    test('should request live endpoint when period is LIVE', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse(sampleMetricsJson);
      });
      gateway = AnalyticsHttpGateway(dio, mockTokenStorage);

      // Act
      final result = await gateway.getDashboardMetrics(deviceId: 'device-001', period: 'LIVE');

      // Assert
      expect(capturedOptions.path, equals('/api/v1/analytics/devices/device-001/live'));
      expect(capturedOptions.queryParameters, isEmpty);
      expect(result.averageCo2, equals(480.0));
    });

    test('should request historical endpoint and include period when period is not live', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse(sampleMetricsJson);
      });
      gateway = AnalyticsHttpGateway(dio, mockTokenStorage);

      // Act
      final result = await gateway.getDashboardMetrics(
        deviceId: 'device-002',
        period: 'DAY',
        startDate: '2026-10-01T00:00:00Z',
        endDate: '2026-10-02T00:00:00Z',
      );

      // Assert
      expect(capturedOptions.path, equals('/api/v1/analytics/devices/device-002/historical'));
      expect(capturedOptions.queryParameters, equals({
        'period': 'DAY',
        'startDate': '2026-10-01T00:00:00Z',
        'endDate': '2026-10-02T00:00:00Z',
      }));
      expect(result.averagePm2_5, equals(9.0));
    });

    test('should throw DioException when server responds with 404', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return FakeHttpClientAdapter.jsonResponse(
          {'message': 'Device not found'},
          statusCode: 404,
        );
      });
      gateway = AnalyticsHttpGateway(dio, mockTokenStorage);

      // Act & Assert
      expect(
        () => gateway.getDashboardMetrics(deviceId: 'unknown-id'),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 404)),
      );
    });

    test('should throw DioException when server responds with 500', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return FakeHttpClientAdapter.jsonResponse(
          {'error': 'Internal server error'},
          statusCode: 500,
        );
      });
      gateway = AnalyticsHttpGateway(dio, mockTokenStorage);

      // Act & Assert
      expect(
        () => gateway.getDashboardMetrics(deviceId: 'error-id'),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 500)),
      );
    });
  });

  group('AnalyticsHttpGateway - getTrends', () {
    test('should request trends endpoint with query parameters', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse(sampleTrendsJson);
      });
      gateway = AnalyticsHttpGateway(dio, mockTokenStorage);

      // Act
      final result = await gateway.getTrends(
        deviceId: 'device-003',
        period: 'WEEK',
        startDate: '2026-09-25T00:00:00Z',
        endDate: '2026-10-02T00:00:00Z',
      );

      // Assert
      expect(capturedOptions.method, equals('GET'));
      expect(capturedOptions.path, equals('/api/v1/analytics/devices/device-003/trends'));
      expect(capturedOptions.queryParameters, equals({
        'period': 'WEEK',
        'startDate': '2026-09-25T00:00:00Z',
        'endDate': '2026-10-02T00:00:00Z',
      }));
      expect(result.dataPoints.length, equals(1));
      expect(result.dataPoints.first.aqiValue, equals(30.0));
    });

    test('should request trends endpoint without query parameters when none provided', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        capturedOptions = options;
        return FakeHttpClientAdapter.jsonResponse(sampleTrendsJson);
      });
      gateway = AnalyticsHttpGateway(dio, mockTokenStorage);

      // Act
      final result = await gateway.getTrends(deviceId: 'device-004');

      // Assert
      expect(capturedOptions.path, equals('/api/v1/analytics/devices/device-004/trends'));
      expect(capturedOptions.queryParameters, isEmpty);
      expect(result.dataPoints, isNotEmpty);
    });

    test('should throw DioException when trends request fails', () async {
      // Arrange
      dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
        return FakeHttpClientAdapter.jsonResponse(
          {'message': 'Data unavailable'},
          statusCode: 503,
        );
      });
      gateway = AnalyticsHttpGateway(dio, mockTokenStorage);

      // Act & Assert
      expect(
        () => gateway.getTrends(deviceId: 'fail-device'),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 503)),
      );
    });
  });
}
