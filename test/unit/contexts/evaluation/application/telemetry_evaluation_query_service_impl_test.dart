import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/evaluation/application/internal/queryservices/telemetry_evaluation_query_service_impl.dart';
import 'package:mobile/evaluation/domain/model/queries/get_latest_telemetry_evaluation_by_device.query.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/device_id.valueobject.dart';
import 'package:mobile/evaluation/infrastructure/api/gateways/telemetry_evaluation.gateway.dart';

class MockTelemetryEvaluationGateway extends Mock implements TelemetryEvaluationGateway {}

void main() {
  group('TelemetryEvaluationQueryServiceImpl', () {
    late MockTelemetryEvaluationGateway mockGateway;
    late TelemetryEvaluationQueryServiceImpl service;

    setUp(() {
      mockGateway = MockTelemetryEvaluationGateway();
      service = TelemetryEvaluationQueryServiceImpl(mockGateway);
    });

    test('should return Right(TelemetryEvaluationReadModel) when gateway returns raw data successfully', () async {
      // Arrange
      const deviceIdStr = 'device-abc-123';
      final query = GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: EvaluationDeviceId(deviceIdStr),
      );
      final rawData = {
        'id': 'eval-001',
        'deviceId': deviceIdStr,
        'uptime': 7200,
        'connectivity': {
          'status': 'ONLINE',
          'network': 'WIFI',
          'signalStrength': -42,
        },
        'healthStatus': 1,
        'status': 'HEALTHY',
        'recordedAt': '2026-10-02T14:30:00.000Z',
      };

      when(() => mockGateway.getLatestByDeviceRaw(deviceIdStr))
          .thenAnswer((_) async => rawData);

      // Act
      final result = await service.handleGetLatestByDevice(query);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (readModel) {
          expect(readModel.id, equals('eval-001'));
          expect(readModel.deviceId, equals(deviceIdStr));
          expect(readModel.uptimeSeconds, equals(7200));
          expect(readModel.connectivity.status, equals('ONLINE'));
          expect(readModel.connectivity.network, equals('WIFI'));
          expect(readModel.connectivity.signalStrength, equals(-42));
          expect(readModel.healthStatus, equals(1));
          expect(readModel.status, equals('HEALTHY'));
          expect(readModel.recordedAt, equals(DateTime.parse('2026-10-02T14:30:00.000Z')));
        },
      );
      verify(() => mockGateway.getLatestByDeviceRaw(deviceIdStr)).called(1);
      verifyNoMoreInteractions(mockGateway);
    });

    test('should return Left(Failure) with statusCode and backend message when DioException occurs with response data', () async {
      // Arrange
      const deviceIdStr = 'device-not-found';
      final query = GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: EvaluationDeviceId(deviceIdStr),
      );
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/evaluations/devices/$deviceIdStr/latest'),
        response: Response(
          requestOptions: RequestOptions(path: '/evaluations/devices/$deviceIdStr/latest'),
          statusCode: 404,
          data: {'message': 'Device evaluation record not found'},
        ),
        type: DioExceptionType.badResponse,
      );

      when(() => mockGateway.getLatestByDeviceRaw(deviceIdStr))
          .thenThrow(dioException);

      // Act
      final result = await service.handleGetLatestByDevice(query);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure.statusCode, equals(404));
          expect(failure.message, equals('Device evaluation record not found'));
        },
        (readModel) => fail('Expected Left but got Right: $readModel'),
      );
      verify(() => mockGateway.getLatestByDeviceRaw(deviceIdStr)).called(1);
    });

    test('should return Left(Failure) with error message when DioException occurs without response data', () async {
      // Arrange
      const deviceIdStr = 'device-timeout';
      final query = GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: EvaluationDeviceId(deviceIdStr),
      );
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/evaluations/devices/$deviceIdStr/latest'),
        message: 'Connection timed out',
        type: DioExceptionType.connectionTimeout,
      );

      when(() => mockGateway.getLatestByDeviceRaw(deviceIdStr))
          .thenThrow(dioException);

      // Act
      final result = await service.handleGetLatestByDevice(query);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure.statusCode, isNull);
          expect(failure.message, equals('Connection timed out'));
        },
        (readModel) => fail('Expected Left but got Right: $readModel'),
      );
      verify(() => mockGateway.getLatestByDeviceRaw(deviceIdStr)).called(1);
    });

    test('should return Left(Failure) with stripped exception message when generic Exception occurs', () async {
      // Arrange
      const deviceIdStr = 'device-error';
      final query = GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: EvaluationDeviceId(deviceIdStr),
      );

      when(() => mockGateway.getLatestByDeviceRaw(deviceIdStr))
          .thenThrow(Exception('Unexpected parse error'));

      // Act
      final result = await service.handleGetLatestByDevice(query);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure.statusCode, isNull);
          expect(failure.message, equals('Unexpected parse error'));
        },
        (readModel) => fail('Expected Left but got Right: $readModel'),
      );
      verify(() => mockGateway.getLatestByDeviceRaw(deviceIdStr)).called(1);
    });

    test('should return Left(Failure) with fallback message when non-Exception error is thrown', () async {
      // Arrange
      const deviceIdStr = 'device-unknown-error';
      final query = GetLatestTelemetryEvaluationByDeviceQuery(
        deviceId: EvaluationDeviceId(deviceIdStr),
      );

      when(() => mockGateway.getLatestByDeviceRaw(deviceIdStr))
          .thenAnswer((_) => throw 'Fatal unknown error string');

      // Act
      final result = await service.handleGetLatestByDevice(query);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure.statusCode, isNull);
          expect(failure.message, equals('An unexpected error occurred'));
        },
        (readModel) => fail('Expected Left but got Right: $readModel'),
      );
      verify(() => mockGateway.getLatestByDeviceRaw(deviceIdStr)).called(1);
    });
  });
}
