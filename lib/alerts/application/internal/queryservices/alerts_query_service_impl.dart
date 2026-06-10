import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';

import 'package:mobile/alerts/domain/model/queries/get_alerts.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_device.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_by_space.query.dart';
import 'package:mobile/alerts/domain/model/queries/get_alerts_daily_summary.query.dart';

import 'package:mobile/alerts/domain/model/valueobjects/alert_page.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/daily_alert_count.valueobject.dart';

import 'package:mobile/alerts/domain/services/alerts.query-service.dart';
import 'package:mobile/alerts/infrastructure/api/gateways/alerts.gateway.dart';

import 'package:mobile/alerts/interfaces/rest/transform/alerts_transform.dart';

class AlertsQueryServiceImpl implements AlertsQueryService {
  final AlertsGateway _gateway;

  AlertsQueryServiceImpl(this._gateway);

  @override
  Future<Either<Failure, AlertPage>> handleGetAlerts(
    GetAlertsQuery query, {
    List<AlertStatus>? status,
  }) async {
    try {
      final resource = await _gateway.getAlerts(
        page: query.page,
        size: query.size,
        status: _statusApiValues(status),
      );

      return Right(
        alertPageResourceToDomain(resource),
      );
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (_) {
      return const Left(
        Failure('An unexpected error occurred'),
      );
    }
  }

  @override
  Future<Either<Failure, AlertPage>> handleGetAlertsByDevice(
    GetAlertsByDeviceQuery query, {
    List<AlertStatus>? status,
  }) async {
    try {
      final resource = await _gateway.getAlertsByDevice(
        deviceId: query.deviceId,
        page: query.page,
        size: query.size,
        status: _statusApiValues(status),
      );

      return Right(
        alertPageResourceToDomain(resource),
      );
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (_) {
      return const Left(
        Failure('An unexpected error occurred'),
      );
    }
  }

  @override
  Future<Either<Failure, AlertPage>> handleGetAlertsBySpace(
    GetAlertsBySpaceQuery query, {
    List<AlertStatus>? status,
  }) async {
    try {
      final resource = await _gateway.getAlertsBySpace(
        spaceId: query.spaceId,
        page: query.page,
        size: query.size,
        status: _statusApiValues(status),
      );

      return Right(
        alertPageResourceToDomain(resource),
      );
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (_) {
      return const Left(
        Failure('An unexpected error occurred'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DailyAlertCount>>> handleGetDailySummary(
      GetAlertDailySummaryQuery query,
      ) async {
    try {
      final resources = await _gateway.getCurrentUserDailyAlertSummary(
        days: query.days,
      );

      return Right(
        resources
            .map(dailyAlertSummaryResourceToDomain)
            .toList(),
      );
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (_) {
      return const Left(
        Failure('An unexpected error occurred'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DailyAlertCount>>> handleGetDailySummaryBySpace(
      String spaceId,
      int days,
      ) async {
    try {
      final resources = await _gateway.getDailyAlertSummary(
        spaceId: spaceId,
        days: days,
      );

      return Right(
        resources
            .map(dailyAlertSummaryResourceToDomain)
            .toList(),
      );
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (_) {
      return const Left(
        Failure('An unexpected error occurred'),
      );
    }
  }

  Failure _mapError(DioException error) {
    final status = error.response?.statusCode;

    String? serverMessage;

    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      serverMessage = data['message'].toString();
    }

    return Failure(
      serverMessage ?? error.message ?? 'An unexpected error occurred',
      statusCode: status,
    );
  }

  List<String>? _statusApiValues(List<AlertStatus>? status) {
    if (status == null || status.isEmpty) {
      return null;
    }
    return status.map((s) => s.apiValue).toList();
  }
}
