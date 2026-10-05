import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/analytics/domain/model/queries/get_dashboard_metrics.query.dart';
import 'package:mobile/analytics/domain/model/queries/get_trends.query.dart';
import 'package:mobile/analytics/domain/model/valueobjects/dashboard_metrics.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/live_telemetry.valueobject.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';
import 'package:mobile/analytics/domain/services/analytics.query-service.dart';
import 'package:mobile/analytics/interfaces/pages/analytics_cubit.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_transform.dart';
import 'package:mobile/analytics/interfaces/rest/resources/dashboard_metrics.resource.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/devices/domain/model/readmodels/device.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/device_page.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/organization.read_model.dart';
import 'package:mobile/devices/domain/model/readmodels/space.read_model.dart';
import 'package:mobile/devices/domain/model/queries/get_devices_by_space.query.dart';
import 'package:mobile/devices/domain/model/queries/get_spaces_by_organization.query.dart';
import 'package:mobile/devices/domain/model/queries/get_user_organizations.query.dart';
import 'package:mobile/devices/domain/model/valueobjects/organization_id.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';
import 'package:mobile/devices/domain/services/devices.query-service.dart';
import 'package:mobile/devices/domain/services/organizations.query-service.dart';
import 'package:mobile/devices/domain/services/spaces.query-service.dart';
import 'package:mocktail/mocktail.dart';

import '../../analytics_fixtures.dart';

class MockAnalyticsQueryService extends Mock implements AnalyticsQueryService {}

class MockOrganizationsQueryService extends Mock
    implements OrganizationsQueryService {}

class MockSpacesQueryService extends Mock implements SpacesQueryService {}

class MockDevicesQueryService extends Mock implements DevicesQueryService {}

/// Builds the domain aggregate the happy-path metrics stub returns, going
/// through the production resource → domain transform.
DashboardMetrics liveDashboardMetrics() {
  return dashboardMetricsResourceToDomain(
    DashboardMetricsResource.fromJson(
      dashboardMetricsJson(
        aqiValue: 42,
        aqiCategory: 'Good',
        averageCo2: 612,
        averagePm2_5: 8.4,
        averageTemperature: 21.6,
        averageHumidity: 48.2,
        co2DeltaPercentage: 3.5,
        pm2_5DeltaPercentage: -18.5,
        temperatureDeltaPercentage: 1.5,
        calculatedAt: '2024-05-01T10:00:00Z',
      ),
    ),
  );
}


void main() {
  late MockAnalyticsQueryService analytics;
  late MockOrganizationsQueryService organizations;
  late MockSpacesQueryService spaces;
  late MockDevicesQueryService devices;
  late StreamController<LiveTelemetry> telemetry;
  late AnalyticsCubit cubit;

  OrganizationReadModel organization(String id, String name) {
    return OrganizationReadModel(
      id: id,
      name: name,
      ownerUserId: 'user-1',
      createdAt: DateTime.utc(2024, 1, 1),
      updatedAt: DateTime.utc(2024, 1, 1),
    );
  }

  SpaceReadModel space(String id, String name) {
    return SpaceReadModel(
      id: id,
      name: name,
      organizationId: 'org-1',
      ownerUserId: 'user-1',
      createdAt: DateTime.utc(2024, 1, 1),
      updatedAt: DateTime.utc(2024, 1, 1),
    );
  }

  DeviceReadModel device(String id, String name) {
    return DeviceReadModel(
      id: id,
      serialNumber: 'SN-$id',
      name: name,
      status: 'ACTIVE',
      spaceId: 'space-1',
      ownerUserId: 'user-1',
      configuration: const <String, String>{},
      thresholds: const <Object?>[],
      hardwareId: 'hw-$id',
      deviceType: 'ENV',
      activatedAt: DateTime.utc(2024, 1, 1),
      lastSeenAt: DateTime.utc(2024, 5, 1),
      createdAt: DateTime.utc(2024, 1, 1),
      updatedAt: DateTime.utc(2024, 1, 1),
    );
  }

  /// Stubs the whole happy path: one organization, one space, one device, a
  /// metrics snapshot, a two-point trend series and a live telemetry stream.
  void stubHappyPath() {
    when(
      () => organizations.handleGetUserOrganizations(any()),
    ).thenAnswer((_) async => Right([organization('org-1', 'Acme')]));
    when(
      () => spaces.handleGetSpacesByOrganization(any()),
    ).thenAnswer((_) async => Right([space('space-1', 'Living room')]));
    when(
      () => devices.handleGetDevicesBySpace(any()),
    ).thenAnswer(
      (_) async => Right(
        DevicePageReadModel(
          content: [device('device-1', 'Sensor A')],
          totalElements: 1,
          number: 0,
          size: 100,
        ),
      ),
    );
    when(
      () => analytics.handleGetDashboardMetrics(any()),
    ).thenAnswer((_) async => Right(liveDashboardMetrics()));
    when(
      () => analytics.handleGetTrends(any()),
    ).thenAnswer((_) async => Right(<TrendPoint>[
          buildTrendPoint(timestamp: '2024-05-01T09:00:00Z', aqiValue: 10),
          buildTrendPoint(timestamp: '2024-05-01T09:05:00Z', aqiValue: 20),
        ]));
    when(() => analytics.handleStreamLiveTelemetry(any()))
        .thenAnswer((_) => telemetry.stream);
  }

  setUpAll(() {
    registerFallbackValue(const GetUserOrganizationsQuery());
    registerFallbackValue(
      GetSpacesByOrganizationQuery(organizationId: OrganizationId('org-1')),
    );
    registerFallbackValue(GetDevicesBySpaceQuery(spaceId: SpaceId('space-1')));
    registerFallbackValue(
      const GetDashboardMetricsQuery(deviceId: 'device-1'),
    );
    registerFallbackValue(const GetTrendsQuery(deviceId: 'device-1'));
  });

  setUp(() {
    analytics = MockAnalyticsQueryService();
    organizations = MockOrganizationsQueryService();
    spaces = MockSpacesQueryService();
    devices = MockDevicesQueryService();
    telemetry = StreamController<LiveTelemetry>.broadcast();
    cubit = AnalyticsCubit(analytics, organizations, spaces, devices);
    stubHappyPath();
  });

  tearDown(() async {
    await cubit.close();
    await telemetry.close();
  });

  group('AnalyticsCubit initial state', () {
    test('should start on the live period with the AQI metric and nothing '
        'selected', () {
      // Arrange / Act — the cubit was constructed in setUp.

      // Assert
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.selectedPeriod, 'LIVE');
      expect(cubit.state.isLive, isTrue);
      expect(cubit.state.selectedMetric, 'aqiValue');
      expect(cubit.state.selectedOrgId, isNull);
      expect(cubit.state.selectedSpaceId, isNull);
      expect(cubit.state.selectedDeviceId, isNull);
      expect(cubit.state.organizations, isEmpty);
      expect(cubit.state.liveData, isNull);
      expect(cubit.state.trendDataPoints, isEmpty);
      expect(cubit.state.secondsSinceUpdate, 0);
      expect(cubit.state.hasData, isFalse);
    });

    test('should not touch any collaborator before load is called', () {
      // Arrange / Act — no interaction yet.

      // Assert
      verifyNever(() => organizations.handleGetUserOrganizations(any()));
      verifyNever(() => spaces.handleGetSpacesByOrganization(any()));
      verifyNever(() => devices.handleGetDevicesBySpace(any()));
      verifyNever(() => analytics.handleGetDashboardMetrics(any()));
      verifyNever(() => analytics.handleGetTrends(any()));
      verifyNever(() => analytics.handleStreamLiveTelemetry(any()));
    });
  });

  group('AnalyticsCubit.load', () {
    test('should emit a loading state before the organization request '
        'resolves', () async {
      // Arrange
      final states = <AnalyticsState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);
      final gate = Completer<void>();
      when(
        () => organizations.handleGetUserOrganizations(any()),
      ).thenAnswer((_) async {
        await gate.future;
        return Right([organization('org-1', 'Acme')]);
      });

      // Act
      final load = cubit.load();
      await pumpEventQueue();

      // Assert — the request is still in flight.
      expect(cubit.state.isLoading, isTrue);
      expect(
        states.any((s) => s.isLoading),
        isTrue,
        reason: 'expected an intermediate loading state',
      );

      gate.complete();
      await load;
      await pumpEventQueue();
      expect(states.last.isLoading, isFalse);
      expect(states.last.organizations.single.id, 'org-1');
      await subscription.cancel();
    });

    test('should select the first organization, space and device and load '
        'their analytics', () async {
      // Arrange — happy path stubs.

      // Act
      await cubit.load();
      await pumpEventQueue();

      // Assert
      expect(cubit.state.organizations.single.id, 'org-1');
      expect(cubit.state.selectedOrgId, 'org-1');
      expect(cubit.state.spaces.single.id, 'space-1');
      expect(cubit.state.selectedSpaceId, 'space-1');
      expect(cubit.state.devices.single.id, 'device-1');
      expect(cubit.state.selectedDeviceId, 'device-1');
      expect(cubit.state.errorMessage, isNull);
      final spacesQuery = verify(
        () => spaces.handleGetSpacesByOrganization(captureAny()),
      ).captured.single as GetSpacesByOrganizationQuery;
      expect(spacesQuery.organizationId.value, 'org-1');
      final deviceQuery = verify(
        () => devices.handleGetDevicesBySpace(captureAny()),
      ).captured.single as GetDevicesBySpaceQuery;
      expect(deviceQuery.spaceId.value, 'space-1');
      expect(deviceQuery.size, 100);
    });

    test('should expose the loaded snapshot and trend series on the state',
        () async {
      // Arrange — happy path stubs.

      // Act
      await cubit.load();
      await pumpEventQueue();

      // Assert
      expect(cubit.state.liveData, isNotNull);
      expect(cubit.state.liveData!.aqi.value, 42);
      expect(cubit.state.liveData!.co2.value, 612);
      expect(cubit.state.liveData!.calculatedAt, '2024-05-01T10:00:00Z');
      expect(cubit.state.trendDataPoints, hasLength(2));
      expect(cubit.state.trendDataPoints.first.aqiValue, 10);
      expect(cubit.state.trendDataPoints.last.aqiValue, 20);
      expect(cubit.state.hasData, isTrue);
      expect(cubit.state.isLoading, isFalse);
    });

    test('should request the live metrics snapshot and the daily trend series '
        'for the selected device', () async {
      // Arrange — happy path stubs.

      // Act
      await cubit.load();
      await pumpEventQueue();

      // Assert
      final metricsQuery = verify(
        () => analytics.handleGetDashboardMetrics(captureAny()),
      ).captured.single as GetDashboardMetricsQuery;
      expect(metricsQuery.deviceId, 'device-1');
      expect(metricsQuery.period, 'LIVE');
      expect(metricsQuery.startDate, isNull);
      expect(metricsQuery.endDate, isNull);

      final trendsQuery = verify(
        () => analytics.handleGetTrends(captureAny()),
      ).captured.single as GetTrendsQuery;
      expect(trendsQuery.deviceId, 'device-1');
      expect(trendsQuery.period, 'DAY');
      expect(trendsQuery.startDate, isNull);
      expect(trendsQuery.endDate, isNull);

      verify(
        () => analytics.handleStreamLiveTelemetry(captureAny()),
      ).called(1);
    });

    test('should surface the organization failure message when the '
        'organization request fails', () async {
      // Arrange
      when(
        () => organizations.handleGetUserOrganizations(any()),
      ).thenAnswer((_) async => const Left(Failure('boom', statusCode: 500)));

      // Act
      await cubit.load();
      await pumpEventQueue();

      // Assert
      expect(
        cubit.state.errorMessage,
        'Failed to load organizations. Please try again.',
      );
      expect(cubit.state.isLoading, isFalse);
      verifyNever(() => analytics.handleGetDashboardMetrics(any()));
    });

    test('should surface the space failure message when the space request '
        'fails', () async {
      // Arrange
      when(() => spaces.handleGetSpacesByOrganization(any()))
          .thenAnswer((_) async => const Left(Failure('boom')));

      // Act
      await cubit.load();
      await pumpEventQueue();

      // Assert
      expect(cubit.state.errorMessage, 'Failed to load spaces.');
      expect(cubit.state.selectedOrgId, 'org-1');
      expect(cubit.state.selectedSpaceId, isNull);
      expect(cubit.state.isLoading, isFalse);
    });

    test('should surface the device failure message when the device request '
        'fails', () async {
      // Arrange
      when(() => devices.handleGetDevicesBySpace(any()))
          .thenAnswer((_) async => const Left(Failure('boom')));

      // Act
      await cubit.load();
      await pumpEventQueue();

      // Assert
      expect(cubit.state.errorMessage, 'Failed to load devices.');
      expect(cubit.state.selectedDeviceId, isNull);
      expect(cubit.state.isLoading, isFalse);
    });

    test('should stop loading without selecting anything when the organization '
        'has no spaces', () async {
      // Arrange
      when(
        () => spaces.handleGetSpacesByOrganization(any()),
      ).thenAnswer((_) async => Right(<SpaceReadModel>[]));

      // Act
      await cubit.load();
      await pumpEventQueue();

      // Assert
      expect(cubit.state.spaces, isEmpty);
      expect(cubit.state.selectedSpaceId, isNull);
      expect(cubit.state.selectedDeviceId, isNull);
      expect(cubit.state.isLoading, isFalse);
      verifyNever(() => analytics.handleGetDashboardMetrics(any()));
    });
  });

  group('AnalyticsCubit selection', () {
    test('should ignore fetchData while no device is selected', () async {
      // Arrange — the cubit has only been constructed.

      // Act
      await cubit.fetchData();

      // Assert
      verifyNever(() => analytics.handleGetDashboardMetrics(any()));
      verifyNever(() => analytics.handleGetTrends(any()));
      expect(cubit.state.isLoading, isFalse);
    });

    test('should clear the previous selection when another organization is '
        'chosen', () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      when(
        () => organizations.handleGetUserOrganizations(any()),
      ).thenAnswer(
        (_) async => Right([
          organization('org-1', 'Acme'),
          organization('org-2', 'Globex'),
        ]),
      );

      // Act
      await cubit.selectOrganization('org-2');
      await pumpEventQueue();

      // Assert
      expect(cubit.state.selectedOrgId, 'org-2');
      expect(cubit.state.spaces.single.id, 'space-1');
      final spacesCalls = verify(
        () => spaces.handleGetSpacesByOrganization(captureAny()),
      ).captured;
      expect(spacesCalls, hasLength(2));
      expect(
        (spacesCalls.last as GetSpacesByOrganizationQuery).organizationId.value,
        'org-2',
      );
    });

    test('should store the chosen metric so the dashboard can highlight it',
        () {
      // Arrange — a constructed cubit.

      // Act
      cubit.selectMetric('co2');

      // Assert
      expect(cubit.state.selectedMetric, 'co2');
    });

    test('should refetch analytics and restart the live stream when a device '
        'is selected again', () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      clearInteractions(analytics);

      // Act
      await cubit.selectDevice('device-1');
      await pumpEventQueue();

      // Assert
      verify(() => analytics.handleGetDashboardMetrics(any())).called(1);
      verify(() => analytics.handleGetTrends(any())).called(1);
      verify(() => analytics.handleStreamLiveTelemetry(any())).called(1);
      expect(cubit.state.liveData, isNotNull);
      expect(cubit.state.secondsSinceUpdate, 0);
    });

    test('should store the chosen period and clear any custom date range',
        () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();

      // Act
      cubit.selectPeriod('Day');
      await pumpEventQueue();

      // Assert
      expect(cubit.state.selectedPeriod, 'Day');
      expect(cubit.state.isLive, isFalse);
      expect(cubit.state.startDate, isNull);
      expect(cubit.state.endDate, isNull);
    });
  });

  group('AnalyticsCubit fetchData failures', () {
    test('should flag live data as unavailable and name the device when the '
        'metrics request answers 404', () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      when(
        () => analytics.handleGetDashboardMetrics(any()),
      ).thenAnswer(
        (_) async => Left(
          const Failure('device-1 has no recent live telemetry', statusCode: 404),
        ),
      );

      // Act
      await cubit.fetchData();
      await pumpEventQueue();

      // Assert
      expect(cubit.state.liveUnavailable, isTrue);
      expect(
        cubit.state.liveUnavailableMessage,
        '"Sensor A" has no recent live telemetry',
      );
      expect(cubit.state.liveData, isNull);
      expect(cubit.state.errorMessage, isNull);
    });

    test('should clear the snapshot without an error message when the metrics '
        'request fails with a non-404 status', () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      when(
        () => analytics.handleGetDashboardMetrics(any()),
      ).thenAnswer((_) async => const Left(Failure('boom', statusCode: 500)));

      // Act
      await cubit.fetchData();
      await pumpEventQueue();

      // Assert
      expect(cubit.state.liveData, isNull);
      expect(cubit.state.liveUnavailable, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });

    test('should empty the trend series and stop loading when the trends '
        'request fails', () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      expect(cubit.state.trendDataPoints, hasLength(2));
      when(
        () => analytics.handleGetTrends(any()),
      ).thenAnswer((_) async => const Left(Failure('boom', statusCode: 500)));

      // Act
      await cubit.fetchData();
      await pumpEventQueue();

      // Assert
      expect(cubit.state.trendDataPoints, isEmpty);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.liveData, isNotNull);
    });

    test('should keep an empty trend list as valid data when the device has no '
        'history yet', () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      when(
        () => analytics.handleGetTrends(any()),
      ).thenAnswer((_) async => Right(<TrendPoint>[]));

      // Act
      await cubit.fetchData();
      await pumpEventQueue();

      // Assert
      expect(cubit.state.trendDataPoints, isEmpty);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.liveData, isNotNull);
    });
  });

  group('AnalyticsCubit live telemetry', () {
    test('should derive the AQI from the streamed PM2.5 reading and append a '
        'trend point', () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      final initialPoints = cubit.state.trendDataPoints.length;

      // Act
      telemetry.add(
        buildLiveTelemetry(
          co2: 700,
          pm2_5: 12.5,
          temperature: 22.5,
          humidity: 55,
          timestamp: '2024-05-01T10:05:00Z',
        ),
      );
      await pumpEventQueue();

      // Assert
      expect(cubit.state.liveData!.aqi.value, 52);
      expect(cubit.state.liveData!.aqi.category, 'Moderate');
      expect(cubit.state.liveData!.co2.value, 700);
      expect(cubit.state.liveData!.pm2_5.value, 12.5);
      expect(cubit.state.liveData!.temperature.value, 22.5);
      expect(cubit.state.liveData!.humidity.value, 55);
      expect(cubit.state.liveData!.calculatedAt, '2024-05-01T10:05:00Z');
      expect(cubit.state.trendDataPoints, hasLength(initialPoints + 1));
      expect(cubit.state.trendDataPoints.last.timestamp, '2024-05-01T10:05:00Z');
      expect(cubit.state.trendDataPoints.last.aqiValue, 52);
      expect(cubit.state.liveUnavailable, isFalse);
      expect(cubit.state.secondsSinceUpdate, 0);
    });

    test('should carry the previous comparison percentages into the merged '
        'snapshot', () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      final previous = cubit.state.liveData!;

      // Act
      telemetry.add(buildLiveTelemetry(pm2_5: 12.5));
      await pumpEventQueue();

      // Assert
      expect(cubit.state.liveData!.co2.deltaPercentage, previous.co2.deltaPercentage);
      expect(
        cubit.state.liveData!.pm2_5.deltaPercentage,
        previous.pm2_5.deltaPercentage,
      );
      expect(cubit.state.liveData!.pm2_5.value, 12.5);
    });

    test('should start a fresh trend series from the first streamed reading',
        () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      when(
        () => analytics.handleGetTrends(any()),
      ).thenAnswer((_) async => Right(<TrendPoint>[]));
      await cubit.fetchData();
      await pumpEventQueue();

      // Act
      telemetry.add(buildLiveTelemetry(pm2_5: 12.5));
      await pumpEventQueue();

      // Assert
      expect(cubit.state.trendDataPoints, hasLength(1));
      expect(cubit.state.trendDataPoints.single.timestamp, '2024-05-01T10:00:00Z');
    });

    test('should cancel the live subscription when closed so no telemetry '
        'arrives afterwards', () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      var cancelled = false;
      final tracking = StreamController<LiveTelemetry>.broadcast(
        onCancel: () => cancelled = true,
      );
      when(
        () => analytics.handleStreamLiveTelemetry(any()),
      ).thenAnswer((_) => tracking.stream);
      await cubit.selectDevice('device-1');
      await pumpEventQueue();

      // Act
      await cubit.close();

      // Assert
      expect(cancelled, isTrue);
      expect(tracking.hasListener, isFalse);
      await tracking.close();
    });

    test('should not emit a seconds update after closing the cubit', () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      await cubit.close();

      // Act
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Assert
      expect(cubit.isClosed, isTrue);
      expect(cubit.state.secondsSinceUpdate, 0);
    });
  });

  group('AnalyticsCubit disposal safety', () {
    test('should surface a StateError when a pending metrics request resolves '
        'after the cubit was closed', () async {
      // Arrange — a metrics request that never resolves until we say so.
      await cubit.load();
      await pumpEventQueue();
      final metricsCompleter = Completer<Either<Failure, DashboardMetrics>>();
      when(
        () => analytics.handleGetDashboardMetrics(any()),
      ).thenAnswer((_) => metricsCompleter.future);
      final pending = cubit.fetchData();
      await untilCalled(() => analytics.handleGetDashboardMetrics(any()));

      // Act — close while the request is still in flight, then resolve it.
      await cubit.close();
      metricsCompleter.complete(
        Right(buildDashboardMetrics()),
      );

      // Assert — current behaviour: the late emission is not guarded.
      await expectLater(pending, throwsA(isA<StateError>()));
    });
  });

  group('AnalyticsCubit seconds counter', () {
    // The counter runs on a real `Timer.periodic`, so these tests wait on the
    // real clock and assert a lower bound instead of an exact tick count.
    test('should increment the seconds-since-update counter once per second '
        'while a snapshot is present', () async {
      // Arrange
      await cubit.load();
      await pumpEventQueue();
      expect(cubit.state.liveData, isNotNull);
      expect(cubit.state.secondsSinceUpdate, 0);

      // Act
      await Future<void>.delayed(const Duration(milliseconds: 1300));

      // Assert
      expect(cubit.state.secondsSinceUpdate, greaterThanOrEqualTo(1));
      expect(cubit.state.liveData, isNotNull);
    });

    test('should not count seconds while no snapshot is present', () async {
      // Arrange — the metrics request fails, so there is no snapshot to age.
      await cubit.load();
      await pumpEventQueue();
      when(
        () => analytics.handleGetDashboardMetrics(any()),
      ).thenAnswer((_) async => const Left(Failure('boom', statusCode: 500)));

      // Act
      await cubit.selectDevice('device-1');
      await pumpEventQueue();
      expect(cubit.state.liveData, isNull);
      await Future<void>.delayed(const Duration(milliseconds: 1300));

      // Assert
      expect(cubit.state.secondsSinceUpdate, 0);
    });
  });
}

