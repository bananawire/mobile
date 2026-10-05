import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_thresholds_http.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_device_threshold.resource.dart';

import '../../helpers/device_fixtures.dart';
import '../../helpers/fake_http_client_adapter.dart';

void main() {
  late Dio dio;
  late FakeHttpClientAdapter adapter;
  late DeviceThresholdsHttpGateway sut;

  setUp(() {
    adapter = FakeHttpClientAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://clair.test'));
    dio.httpClientAdapter = adapter;
    sut = DeviceThresholdsHttpGateway(dio);
  });

  tearDown(() {
    dio.close(force: true);
  });

  group('DeviceThresholdsHttpGateway.getThresholdsByDevice', () {
    test('should GET the threshold collection and parse every entry', () async {
      // Arrange
      adapter.enqueueJson(<dynamic>[
        deviceThresholdJson(metric: 'PM25', value: 60.0),
        deviceThresholdJson(metric: 'HUMIDITY', value: 80.0),
      ]);

      // Act
      final thresholds = await sut.getThresholdsByDevice('dev-1');

      // Assert
      expect(adapter.singleRequest.method, 'GET');
      expect(adapter.singleRequest.path, '/api/v1/devices/dev-1/thresholds');
      expect(thresholds, hasLength(2));
      expect(thresholds.first.metric, MetricThreshold.pm25);
      expect(thresholds.first.value, 60.0);
      expect(thresholds.last.metric, MetricThreshold.humidity);
    });

    test('should surface a not found response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'no device'}, statusCode: 404);

      // Act / Assert
      await expectLater(
        sut.getThresholdsByDevice('missing'),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 404),
        ),
      );
    });
  });

  group('DeviceThresholdsHttpGateway.getThresholdByMetric', () {
    test('should select the entry whose api metric name matches case insensitively', () async {
      // Arrange
      adapter.enqueueJson(<dynamic>[
        deviceThresholdJson(metric: 'pm25', value: 60.0),
        deviceThresholdJson(metric: 'CO2', value: 900.0),
      ]);

      // Act
      final threshold = await sut.getThresholdByMetric('dev-1', MetricThreshold.co2);

      // Assert
      expect(adapter.singleRequest.path, '/api/v1/devices/dev-1/thresholds');
      expect(threshold.metric, MetricThreshold.co2);
      expect(threshold.value, 900.0);
    });

    test('should throw when no entry matches the requested metric', () async {
      // Arrange
      adapter.enqueueJson(<dynamic>[deviceThresholdJson(metric: 'CO2', value: 900.0)]);

      // Act / Assert
      await expectLater(
        sut.getThresholdByMetric('dev-1', MetricThreshold.pm25),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: Threshold not found for metric: pm25',
          ),
        ),
      );
    });

    test('should throw when the collection is empty', () async {
      // Arrange
      adapter.enqueueJson(<dynamic>[]);

      // Act / Assert
      await expectLater(
        sut.getThresholdByMetric('dev-1', MetricThreshold.humidity),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('DeviceThresholdsHttpGateway.createThreshold', () {
    test('should POST the encoded threshold body to the collection', () async {
      // Arrange
      adapter.enqueueJson(deviceThresholdJson(metric: 'PM25', value: 60.5));

      // Act
      final threshold = await sut.createThreshold(
        'dev-1',
        const UpdateDeviceThresholdResource(
          metric: MetricThreshold.pm25,
          value: 60.5,
          enabled: true,
        ),
      );

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'POST');
      expect(request.path, '/api/v1/devices/dev-1/thresholds');
      expect(request.data, <String, dynamic>{
        'metric': 'PM25',
        'value': 60.5,
        'enabled': true,
      });
      expect(threshold.value, 60.5);
      expect(threshold.enabled, isTrue);
    });

    test('should propagate a conflict response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'exists'}, statusCode: 409);

      // Act / Assert
      await expectLater(
        sut.createThreshold(
          'dev-1',
          const UpdateDeviceThresholdResource(
            metric: MetricThreshold.pm25,
            value: 60.5,
            enabled: true,
          ),
        ),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 409),
        ),
      );
    });
  });

  group('DeviceThresholdsHttpGateway.updateThreshold', () {
    test('should PUT the encoded threshold body to the collection', () async {
      // Arrange
      adapter.enqueueJson(deviceThresholdJson(metric: 'TEMPERATURE', value: 28.7, enabled: false));

      // Act
      final threshold = await sut.updateThreshold(
        'dev-1',
        const UpdateDeviceThresholdResource(
          metric: MetricThreshold.temperature,
          value: 28.7,
          enabled: false,
        ),
      );

      // Assert
      final request = adapter.singleRequest;
      expect(request.method, 'PUT');
      expect(request.path, '/api/v1/devices/dev-1/thresholds');
      expect(request.data, <String, dynamic>{
        'metric': 'TEMPERATURE',
        'value': 28.7,
        'enabled': false,
      });
      expect(threshold.metric, MetricThreshold.temperature);
      expect(threshold.enabled, isFalse);
    });

    test('should propagate a forbidden response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'forbidden'}, statusCode: 403);

      // Act / Assert
      await expectLater(
        sut.updateThreshold(
          'dev-1',
          const UpdateDeviceThresholdResource(
            metric: MetricThreshold.temperature,
            value: 28.7,
            enabled: false,
          ),
        ),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 403),
        ),
      );
    });
  });

  group('DeviceThresholdsHttpGateway.removeThreshold', () {
    test('should DELETE the metric sub resource using its api name', () async {
      // Arrange
      adapter.enqueueEmpty();

      // Act
      await sut.removeThreshold('dev-1', MetricThreshold.temperature);

      // Assert
      expect(adapter.singleRequest.method, 'DELETE');
      expect(adapter.singleRequest.path, '/api/v1/devices/dev-1/thresholds/TEMPERATURE');
    });

    test('should propagate a not found response as a dio exception', () async {
      // Arrange
      adapter.enqueueJson({'message': 'missing'}, statusCode: 404);

      // Act / Assert
      await expectLater(
        sut.removeThreshold('dev-1', MetricThreshold.humidity),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 404),
        ),
      );
    });
  });
}