import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/devices/application/internal/commandservices/device_threshold_command_service_impl.dart';
import 'package:mobile/devices/domain/model/commands/remove_device_threshold.command.dart';
import 'package:mobile/devices/domain/model/commands/write_device_threshold.command.dart';
import 'package:mobile/devices/domain/model/readmodels/device_threshold.read_model.dart';
import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_thresholds.gateway.dart';
import 'package:mobile/devices/interfaces/rest/resources/device_threshold.resource.dart';
import 'package:mobile/devices/interfaces/rest/resources/update_device_threshold.resource.dart';

import '../helpers/device_fixtures.dart';

class _MockDeviceThresholdsGateway extends Mock implements DeviceThresholdsGateway {}

void main() {
  late DeviceThresholdsGateway gateway;
  late DeviceThresholdCommandServiceImpl sut;

  setUpAll(() {
    registerFallbackValue(UpdateDeviceThresholdResource(
      metric: MetricThreshold.pm25,
      value: 1,
      enabled: true,
    ));
    registerFallbackValue(MetricThreshold.pm25);
    registerFallbackValue(DeviceThresholdResource.fromJson(deviceThresholdJson()));
  });

  setUp(() {
    gateway = _MockDeviceThresholdsGateway();
    sut = DeviceThresholdCommandServiceImpl(gateway);
  });

  group('DeviceThresholdCommandServiceImpl.handleWriteThreshold', () {
    test('should create the threshold and map the response when the intent is create', () async {
      // Arrange
      when(
        () => gateway.createThreshold(any(), any()),
      ).thenAnswer((_) async => DeviceThresholdResource.fromJson(deviceThresholdJson(metric: 'CO2', value: 900.0)));
      final command = WriteDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.co2,
        value: 900,
        enabled: true,
        intent: DeviceThresholdWriteIntent.create,
      );

      // Act
      final result = await sut.handleWriteThreshold(command);

      // Assert
      final threshold = result.fold((_) => null, (value) => value);
      expect(threshold, isA<DeviceThresholdReadModel>());
      expect(threshold!.deviceId, 'dev-1');
      expect(threshold.metric, MetricThreshold.co2);
      expect(threshold.value, 900.0);
      expect(threshold.enabled, isTrue);
      expect(threshold.metricLabel, 'CO2');
      expect(threshold.metricUnit, 'ppm');
      verifyNever(() => gateway.updateThreshold(any(), any()));
    });

    test('should update the threshold and map the response when the intent is update', () async {
      // Arrange
      when(
        () => gateway.updateThreshold(any(), any()),
      ).thenAnswer((_) async => DeviceThresholdResource.fromJson(deviceThresholdJson(metric: 'TEMPERATURE', value: 28.7)));
      final command = WriteDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.temperature,
        value: 28.7,
        enabled: false,
        intent: DeviceThresholdWriteIntent.update,
      );

      // Act
      final result = await sut.handleWriteThreshold(command);

      // Assert
      final threshold = result.fold((_) => null, (value) => value);
      expect(threshold!.metric, MetricThreshold.temperature);
      expect(threshold.value, 28.7);
      // The read model mirrors the server payload, which reports enabled: true.
      expect(threshold.enabled, isTrue);
      verifyNever(() => gateway.createThreshold(any(), any()));
    });

    test('should return the enabled flag reported by the server instead of the requested one', () async {
      // Arrange
      when(() => gateway.updateThreshold(any(), any())).thenAnswer(
        (_) async => DeviceThresholdResource.fromJson(
          deviceThresholdJson(metric: 'HUMIDITY', value: 80.0, enabled: false),
        ),
      );
      final command = WriteDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.humidity,
        value: 80,
        enabled: true,
        intent: DeviceThresholdWriteIntent.update,
      );

      // Act
      final result = await sut.handleWriteThreshold(command);

      // Assert
      final threshold = result.fold((_) => null, (value) => value);
      expect(threshold!.enabled, isFalse);
      expect(threshold.metric, MetricThreshold.humidity);
    });

    test('should submit the device id and the api encoded threshold body', () async {
      // Arrange
      when(
        () => gateway.createThreshold(any(), any()),
      ).thenAnswer((_) async => DeviceThresholdResource.fromJson(deviceThresholdJson()));
      final command = WriteDeviceThresholdCommand(
        deviceId: ' dev-1 ',
        metric: MetricThreshold.pm25,
        value: 60.5,
        enabled: true,
        intent: DeviceThresholdWriteIntent.create,
      );

      // Act
      await sut.handleWriteThreshold(command);

      // Assert
      final captured =
          verify(() => gateway.createThreshold(captureAny(), captureAny())).captured;
      expect(captured[0], ' dev-1 ');
      final resource = captured[1] as UpdateDeviceThresholdResource;
      expect(resource.metric, MetricThreshold.pm25);
      expect(resource.value, 60.5);
      expect(resource.enabled, isTrue);
    });

    test('should translate each dio status code into its documented failure message', () async {
      // Arrange
      const expected = <int, String>{
        400: 'Invalid request. Check threshold values.',
        401: 'Session expired. Please sign in again.',
        403: 'Access denied. Device does not belong to you.',
        404: 'Device or threshold not found.',
        409: 'Threshold already exists for this metric.',
        500: 'Server error. Please try again later.',
        503: 'Server error. Please try again later.',
        418: 'Network error. Please check your connection.',
      };
      final command = WriteDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.pm25,
        value: 60,
        enabled: true,
        intent: DeviceThresholdWriteIntent.create,
      );

      for (final entry in expected.entries) {
        when(() => gateway.createThreshold(any(), any())).thenThrow(dioError(entry.key));

        // Act
        final result = await sut.handleWriteThreshold(command);

        // Assert
        final failure = result.fold((f) => f, (_) => null);
        expect(failure!.message, entry.value, reason: 'status ${entry.key}');
      }
    });

    test('should surface a gateway exception message when the payload is malformed', () async {
      // Arrange
      when(() => gateway.createThreshold(any(), any()))
          .thenThrow(Exception('Unknown metric: RADIATION'));
      final command = WriteDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.pm25,
        value: 60,
        enabled: true,
        intent: DeviceThresholdWriteIntent.create,
      );

      // Act
      final result = await sut.handleWriteThreshold(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Unknown metric: RADIATION');
    });

    test('should never read a threshold while writing one', () async {
      // Arrange
      when(
        () => gateway.createThreshold(any(), any()),
      ).thenAnswer((_) async => DeviceThresholdResource.fromJson(deviceThresholdJson()));
      final command = WriteDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.pm25,
        value: 60,
        enabled: true,
        intent: DeviceThresholdWriteIntent.create,
      );

      // Act
      await sut.handleWriteThreshold(command);

      // Assert
      verifyNever(() => gateway.getThresholdsByDevice(any()));
      verifyNever(() => gateway.getThresholdByMetric(any(), any()));
    });
  });

  group('DeviceThresholdCommandServiceImpl.handleRemoveThreshold', () {
    test('should return a successful right carrying no value when the threshold is removed', () async {
      // Arrange
      when(() => gateway.removeThreshold(any(), any())).thenAnswer((_) async {});
      final command = RemoveDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.humidity,
      );

      // Act
      final result = await sut.handleRemoveThreshold(command);

      // Assert
      expect(result.fold((_) => 'left', (_) => 'right'), 'right');
    });

    test('should remove the threshold identified by device id and metric', () async {
      // Arrange
      when(() => gateway.removeThreshold(any(), any())).thenAnswer((_) async {});
      final command = RemoveDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.humidity,
      );

      // Act
      await sut.handleRemoveThreshold(command);

      // Assert
      final captured =
          verify(() => gateway.removeThreshold(captureAny(), captureAny())).captured;
      expect(captured, ['dev-1', MetricThreshold.humidity]);
    });

    test('should report a missing threshold failure when there is nothing to remove', () async {
      // Arrange
      when(() => gateway.removeThreshold(any(), any())).thenThrow(dioError(404));
      final command = RemoveDeviceThresholdCommand(
        deviceId: 'dev-1',
        metric: MetricThreshold.co2,
      );

      // Act
      final result = await sut.handleRemoveThreshold(command);

      // Assert
      final failure = result.fold((f) => f, (_) => null);
      expect(failure!.message, 'Device or threshold not found.');
    });
  });
}