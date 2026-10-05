import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/devices/application/internal/queryservices/device_threshold_query_service_impl.dart';
import 'package:mobile/devices/domain/model/queries/get_device_threshold_by_metric.query.dart';
import 'package:mobile/devices/domain/model/queries/get_device_thresholds.query.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_thresholds.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_threshold.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_device_threshold.resource.dart';

import '../helpers/device_fixtures.dart';

class _MockDeviceThresholdsGateway extends Mock implements DeviceThresholdsGateway {}

void main() {
  late DeviceThresholdsGateway gateway;
  late DeviceThresholdQueryServiceImpl sut;

  setUpAll(() {
    registerFallbackValue(MetricThreshold.pm25);
    registerFallbackValue(UpdateDeviceThresholdResource(
      metric: MetricThreshold.pm25,
      value: 1,
      enabled: true,
    ));
    registerFallbackValue(DeviceThresholdResource.fromJson(deviceThresholdJson()));
  });

  setUp(() {
    gateway = _MockDeviceThresholdsGateway();
    sut = DeviceThresholdQueryServiceImpl(gateway);
  });

  group('DeviceThresholdQueryServiceImpl.handleGetDeviceThresholds', () {
    test('should return every threshold mapped when the gateway answers', () async {
      // Arrange
      when(() => gateway.getThresholdsByDevice(any())).thenAnswer(
        (_) async => [
          DeviceThresholdResource.fromJson(deviceThresholdJson(metric: 'PM25', value: 60.0)),
          DeviceThresholdResource.fromJson(deviceThresholdJson(metric: 'HUMIDITY', value: 80.0)),
        ],
      );
      final query = GetDeviceThresholdsQuery(deviceId: 'dev-1');

      // Act
      final result = await sut.handleGetDeviceThresholds(query);

      // Assert
      final thresholds = result.fold((_) => null, (value) => value);
      expect(thresholds, hasLength(2));
      expect(thresholds!.first.metric, MetricThreshold.pm25);
      expect(thresholds.first.value, 60.0);
      expect(thresholds.first.metricLabel, 'PM2.5');
      expect(thresholds.first.metricUnit, 'µg/m³');
      expect(thresholds.last.metric, MetricThreshold.humidity);
      expect(thresholds.last.metricLabel, 'Humidity');
    });

    test('should ask the gateway for the given device id', () async {
      // Arrange
      when(() => gateway.getThresholdsByDevice(any())).thenAnswer((_) async => []);
      final query = GetDeviceThresholdsQuery(deviceId: ' dev-1 ');

      // Act
      await sut.handleGetDeviceThresholds(query);

      // Assert
      final captured = verify(() => gateway.getThresholdsByDevice(captureAny())).captured;
      expect(captured.single, ' dev-1 ');
    });

    test('should return an empty list when the device has no thresholds', () async {
      // Arrange
      when(() => gateway.getThresholdsByDevice(any())).thenAnswer((_) async => []);
      final query = GetDeviceThresholdsQuery(deviceId: 'dev-1');

      // Act
      final result = await sut.handleGetDeviceThresholds(query);

      // Assert
      final thresholds = result.fold((_) => null, (value) => value);
      expect(thresholds, isEmpty);
    });

    test('should surface a gateway exception message as the failure', () async {
      // Arrange
      when(() => gateway.getThresholdsByDevice(any())).thenThrow(Exception('Invalid threshold value'));
      final query = GetDeviceThresholdsQuery(deviceId: 'dev-1');

      // Act
      final result = await sut.handleGetDeviceThresholds(query);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Invalid threshold value');
    });

    test('should never write while listing thresholds', () async {
      // Arrange
      when(() => gateway.getThresholdsByDevice(any())).thenAnswer((_) async => []);
      final query = GetDeviceThresholdsQuery(deviceId: 'dev-1');

      // Act
      await sut.handleGetDeviceThresholds(query);

      // Assert
      verifyNever(() => gateway.createThreshold(any(), any()));
      verifyNever(() => gateway.updateThreshold(any(), any()));
      verifyNever(() => gateway.removeThreshold(any(), any()));
    });
  });

  group('DeviceThresholdQueryServiceImpl.handleGetDeviceThresholdByMetric', () {
    test('should return the single threshold mapped when the gateway answers', () async {
      // Arrange
      when(() => gateway.getThresholdByMetric(any(), any())).thenAnswer(
        (_) async => DeviceThresholdResource.fromJson(deviceThresholdJson(metric: 'TEMPERATURE', value: 28.7)),
      );
      final query = GetDeviceThresholdByMetricQuery(
        deviceId: 'dev-1',
        metric: MetricThreshold.temperature,
      );

      // Act
      final result = await sut.handleGetDeviceThresholdByMetric(query);

      // Assert
      final threshold = result.fold((_) => null, (value) => value);
      expect(threshold!.metric, MetricThreshold.temperature);
      expect(threshold.value, 28.7);
      expect(threshold.metricLabel, 'Temperature');
      expect(threshold.metricUnit, '°C');
    });

    test('should ask the gateway for the given device id and metric', () async {
      // Arrange
      when(() => gateway.getThresholdByMetric(any(), any())).thenAnswer(
        (_) async => DeviceThresholdResource.fromJson(deviceThresholdJson(metric: 'CO2')),
      );
      final query = GetDeviceThresholdByMetricQuery(
        deviceId: 'dev-1',
        metric: MetricThreshold.co2,
      );

      // Act
      await sut.handleGetDeviceThresholdByMetric(query);

      // Assert
      final captured =
          verify(() => gateway.getThresholdByMetric(captureAny(), captureAny())).captured;
      expect(captured, ['dev-1', MetricThreshold.co2]);
    });

    test('should report a failure when the metric has no configured threshold', () async {
      // Arrange
      when(() => gateway.getThresholdByMetric(any(), any()))
          .thenThrow(Exception('Threshold not found for metric: pm25'));
      final query = GetDeviceThresholdByMetricQuery(
        deviceId: 'dev-1',
        metric: MetricThreshold.pm25,
      );

      // Act
      final result = await sut.handleGetDeviceThresholdByMetric(query);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Threshold not found for metric: pm25');
    });
  });
}