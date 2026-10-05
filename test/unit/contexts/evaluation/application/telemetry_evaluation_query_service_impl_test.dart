import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/evaluation/application/internal/queryservices/telemetry_evaluation_query_service_impl.dart';
import 'package:mobile/evaluation/domain/model/queries/get_latest_telemetry_evaluation_by_device.query.dart';
import 'package:mobile/evaluation/domain/model/readmodels/telemetry_evaluation.read_model.dart';
import 'package:mobile/evaluation/infrastructure/api/gateways/telemetry_evaluation.gateway.dart';

import '../helpers/evaluation_fixtures.dart';

class _MockTelemetryEvaluationGateway extends Mock
    implements TelemetryEvaluationGateway {}

void main() {
  late _MockTelemetryEvaluationGateway gateway;
  late TelemetryEvaluationQueryServiceImpl service;

  setUp(() {
    gateway = _MockTelemetryEvaluationGateway();
    service = TelemetryEvaluationQueryServiceImpl(gateway);
  });

  void stubGatewayPayload(Map<String, dynamic> payload) {
    when(
      () => gateway.getLatestByDeviceRaw(any()),
    ).thenAnswer((_) async => payload);
  }

  /// Builds the 400/401/.../5xx exception dio really raises, so the service is
  /// exercised with the same object it meets in production.
  DioException badResponse(int statusCode, {Map<String, dynamic>? body}) {
    final options = RequestOptions(
      path: '/api/v1/evaluations/devices/device-1/latest',
    );
    final response = Response<Map<String, dynamic>>(
      requestOptions: options,
      statusCode: statusCode,
      data: body ?? <String, dynamic>{'message': 'error $statusCode'},
    );
    return DioException.badResponse(
      statusCode: statusCode,
      requestOptions: options,
      response: response,
    );
  }

  group('TelemetryEvaluationQueryServiceImpl.handleGetLatestByDevice', () {
    test('should return a right read model with the mapped payload when the '
        'gateway succeeds', () async {
      // Arrange
      stubGatewayPayload(buildEvaluationJson());

      // Act
      final result = await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId('device-1'),
        ),
      );

      // Assert
      expect(result.isRight(), isTrue);
      final readModel = result.fold(
        (failure) => fail('expected a Right but got a Left: $failure'),
        (value) => value,
      );
      expect(readModel.id, 'eval-1');
      expect(readModel.deviceId, 'device-1');
      expect(readModel.uptimeSeconds, 7200);
      expect(readModel.healthStatus, 92);
      expect(readModel.status, 'HEALTHY');
      expect(readModel.recordedAt, evaluationRecordedAt);
    });

    test('should copy the connectivity sub-object into the read model '
        'connectivity value object', () async {
      // Arrange
      stubGatewayPayload(
        buildEvaluationJson(
          connectivity: buildConnectivityJson(
            status: 'DEGRADED',
            network: 'cellular',
            signalStrength: -98,
          ),
        ),
      );

      // Act
      final result = await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId(),
        ),
      );

      // Assert
      final readModel = result.getOrElse(
        (failure) => fail('expected a Right but got a Left: $failure'),
      );
      expect(readModel.connectivity.status, 'DEGRADED');
      expect(readModel.connectivity.network, 'cellular');
      expect(readModel.connectivity.signalStrength, -98);
    });

    test('should expose a null signal strength to the ACL instead of '
        'substituting zero', () async {
      // Arrange
      stubGatewayPayload(
        buildEvaluationJson(
          connectivity: buildConnectivityJson(signalStrength: null),
        ),
      );

      // Act
      final result = await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId(),
        ),
      );

      // Assert
      final readModel = result.getOrElse(
        (failure) => fail('expected a Right but got a Left: $failure'),
      );
      expect(readModel.connectivity.signalStrength, isNull);
    });

    test('should forward the trimmed device id value to the gateway '
        'boundary', () async {
      // Arrange
      stubGatewayPayload(buildEvaluationJson());

      // Act
      await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId('device-1'),
        ),
      );

      // Assert
      final captured = verify(
        () => gateway.getLatestByDeviceRaw(captureAny()),
      ).captured;
      expect(captured, <String>['device-1']);
    });

    test('should call the gateway exactly once without retrying when the '
        'request succeeds', () async {
      // Arrange
      stubGatewayPayload(buildEvaluationJson());

      // Act
      await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId(),
        ),
      );

      // Assert
      verify(() => gateway.getLatestByDeviceRaw(any())).called(1);
    });

    test('should return a left failure when the requested device has no '
        'evaluation', () async {
      // Arrange
      when(
        () => gateway.getLatestByDeviceRaw(any()),
      ).thenAnswer((_) async => throw badResponse(404));

      // Act
      final result = await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId('device-404'),
        ),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      final failure = result.fold(
        (value) => value,
        (readModel) => fail('expected a Left but got a Right: $readModel'),
      );
      expect(failure, isA<Failure>());
      expect(failure.message, contains('status code of 404'));
      expect(failure.statusCode, isNull);
    });

    for (final statusCode in <int>[400, 401, 403, 404, 409, 500, 503]) {
      test('should map the $statusCode response into a left failure whose '
          'message mentions the status code', () async {
        // Arrange
        when(
          () => gateway.getLatestByDeviceRaw(any()),
        ).thenAnswer((_) async => throw badResponse(statusCode));

        // Act
        final result = await service.handleGetLatestByDevice(
          GetLatestTelemetryEvaluationByDeviceQuery(
            deviceId: buildEvaluationDeviceId(),
          ),
        );

        // Assert
        expect(result.isLeft(), isTrue);
        final failure = result.fold(
          (value) => value,
          (readModel) => fail('expected a Left but got a Right: $readModel'),
        );
        expect(failure.message, startsWith('DioException [bad response]: '));
        expect(failure.message, contains('$statusCode'));
        expect(failure.statusCode, isNull);
      });
    }

    test('should keep the readable dio description in the failure message '
        'for a bad response', () async {
      // Arrange
      when(
        () => gateway.getLatestByDeviceRaw(any()),
      ).thenAnswer((_) async => throw badResponse(401));

      // Act
      final result = await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId(),
        ),
      );

      // Assert
      final failure = result.fold(
        (value) => value,
        (readModel) => fail('expected a Left but got a Right: $readModel'),
      );
      expect(
        failure.message,
        contains('RequestOptions.validateStatus was configured to throw'),
      );
    });

    test('should map a plain exception to a left failure stripped of the '
        'Exception prefix', () async {
      // Arrange
      when(
        () => gateway.getLatestByDeviceRaw(any()),
      ).thenAnswer((_) async => throw Exception('boom'));

      // Act
      final result = await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId(),
        ),
      );

      // Assert
      final failure = result.fold(
        (value) => value,
        (readModel) => fail('expected a Left but got a Right: $readModel'),
      );
      expect(failure.message, 'boom');
      expect(failure.statusCode, isNull);
    });

    test('should map a non-exception throwable to the generic unexpected '
        'error failure', () async {
      // Arrange
      when(
        () => gateway.getLatestByDeviceRaw(any()),
      ).thenAnswer((_) async => throw StateError('not an exception'));

      // Act
      final result = await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId(),
        ),
      );

      // Assert
      final failure = result.fold(
        (value) => value,
        (readModel) => fail('expected a Left but got a Right: $readModel'),
      );
      expect(failure.message, 'An unexpected error occurred');
    });

    test('should return a left failure when the payload has an invalid '
        'recorded-at timestamp', () async {
      // Arrange
      stubGatewayPayload(buildEvaluationJson(recordedAt: 'not-a-date'));

      // Act
      final result = await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId(),
        ),
      );

      // Assert
      final failure = result.fold(
        (value) => value,
        (readModel) => fail('expected a Left but got a Right: $readModel'),
      );
      expect(failure.message, contains('Invalid date format'));
    });

    test('should return a left failure when the connectivity field is not an '
        'object', () async {
      // Arrange
      stubGatewayPayload(buildEvaluationJson(connectivity: 'ONLINE'));

      // Act
      final result = await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId(),
        ),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      expect(result.isRight(), isFalse);
    });

    test('should still call the gateway exactly once when the payload cannot '
        'be parsed', () async {
      // Arrange
      stubGatewayPayload(buildEvaluationJson(recordedAt: 'not-a-date'));

      // Act
      await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId(),
        ),
      );

      // Assert
      verify(() => gateway.getLatestByDeviceRaw(any())).called(1);
    });

    test('should default the numeric fields of a sparse payload to zero '
        'instead of failing', () async {
      // Arrange
      stubGatewayPayload(<String, dynamic>{
        'recordedAt': evaluationRecordedAtIso,
      });

      // Act
      final result = await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId(),
        ),
      );

      // Assert
      final readModel = result.fold(
        (failure) => fail('expected a Right but got a Left: $failure'),
        (value) => value,
      );
      expect(readModel.id, isEmpty);
      expect(readModel.deviceId, isEmpty);
      expect(readModel.uptimeSeconds, 0);
      expect(readModel.healthStatus, 0);
      expect(readModel.status, isEmpty);
      expect(readModel.connectivity.signalStrength, isNull);
    });

    test('should expose the values the devices ACL relies on for the vitals '
        'snapshot', () async {
      // Arrange
      stubGatewayPayload(
        buildEvaluationJson(
          connectivity: buildConnectivityJson(signalStrength: -67),
          uptime: 7500,
          healthStatus: 92,
        ),
      );

      // Act
      final result = await service.handleGetLatestByDevice(
        GetLatestTelemetryEvaluationByDeviceQuery(
          deviceId: buildEvaluationDeviceId(),
        ),
      );

      // Assert: mirrors DeviceVitalsAcl: dBm, ~/3600 hours, clamp(0, 100).
      final TelemetryEvaluationReadModel readModel = result.fold(
        (failure) => fail('expected a Right but got a Left: $failure'),
        (value) => value,
      );
      expect(readModel.connectivity.signalStrength?.toDouble(), -67.0);
      expect(readModel.uptimeSeconds ~/ 3600, 2);
      expect(readModel.healthStatus.clamp(0, 100).toDouble(), 92.0);
      expect(readModel.recordedAt, evaluationRecordedAt);
    });
  });
}
