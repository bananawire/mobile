import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/valueobjects/trend_point.valueobject.dart';
import 'package:mobile/analytics/interfaces/widgets/trend_chart_card.dart';

import 'helpers/analytics_widget_harness.dart';

const String emptyStateMessage =
    'No historical data in this time range. Try selecting a '
    'different range or checking the device connectivity.';

TrendPoint point({
  String timestamp = '2024-05-01T09:00:00Z',
  double aqiValue = 42,
  double co2 = 612,
  double pm2_5 = 8.4,
  double temperature = 21.6,
  double humidity = 48.2,
}) {
  return TrendPoint(
    timestamp: timestamp,
    aqiValue: aqiValue,
    co2: co2,
    pm2_5: pm2_5,
    temperature: temperature,
    humidity: humidity,
  );
}

void main() {
  Future<void> pumpChart(
    WidgetTester tester, {
    required String title,
    required List<TrendPoint> points,
    required String metric,
    required double? delta,
  }) async {
    await tester.pumpWidget(
      localizedAnalyticsApp(
        TrendChartCard(
          title: title,
          points: points,
          metric: metric,
          delta: delta,
        ),
        width: 340,
      ),
    );
  }

  group('TrendChartCard', () {
    testWidgets('should render the trend title upper cased with the metric',
        (tester) async {
      // Arrange / Act
      await pumpChart(
        tester,
        title: 'AQI',
        points: [point()],
        metric: 'aqiValue',
        delta: null,
      );

      // Assert
      expect(find.text('TREND (AQI)'), findsOneWidget);
    });

    testWidgets('should render the trend title of the selected metric',
        (tester) async {
      // Arrange / Act
      await pumpChart(
        tester,
        title: 'PM2_5',
        points: [point()],
        metric: 'pm2_5',
        delta: null,
      );

      // Assert
      expect(find.text('TREND (PM2_5)'), findsOneWidget);
    });

    testWidgets('should render the empty state message when the device has no '
        'history', (tester) async {
      // Arrange / Act
      await pumpChart(
        tester,
        title: 'AQI',
        points: const <TrendPoint>[],
        metric: 'aqiValue',
        delta: null,
      );

      // Assert
      expect(find.text(emptyStateMessage), findsOneWidget);
      expect(find.text('TREND (AQI)'), findsOneWidget);
      expect(find.text('N/A'), findsOneWidget);
    });

    testWidgets('should paint the series instead of the empty state when '
        'points are available', (tester) async {
      // Arrange / Act
      await pumpChart(
        tester,
        title: 'AQI',
        points: [
          point(timestamp: '2024-05-01T09:00:00Z', aqiValue: 10),
          point(timestamp: '2024-05-01T09:05:00Z', aqiValue: 30),
          point(timestamp: '2024-05-01T09:10:00Z', aqiValue: 20),
        ],
        metric: 'aqiValue',
        delta: null,
      );

      // Assert
      expect(find.text(emptyStateMessage), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should paint a flat series without dividing by a zero range',
        (tester) async {
      // Arrange / Act
      await pumpChart(
        tester,
        title: 'HUMIDITY',
        points: [
          point(humidity: 50),
          point(timestamp: '2024-05-01T09:05:00Z', humidity: 50),
        ],
        metric: 'humidity',
        delta: null,
      );

      // Assert
      expect(tester.takeException(), isNull);
      expect(find.text(emptyStateMessage), findsNothing);
    });

    testWidgets('should render a single-point series without crashing',
        (tester) async {
      // Arrange / Act
      await pumpChart(
        tester,
        title: 'CO₂',
        points: [point()],
        metric: 'co2',
        delta: null,
      );

      // Assert
      expect(tester.takeException(), isNull);
      expect(find.text('TREND (CO₂)'), findsOneWidget);
    });

    testWidgets('should render a rising delta with an up arrow', (tester) async {
      // Arrange / Act
      await pumpChart(
        tester,
        title: 'AQI',
        points: [point()],
        metric: 'aqiValue',
        delta: 4.25,
      );

      // Assert
      expect(find.text('4.3%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('should render a falling delta with a down arrow',
        (tester) async {
      // Arrange / Act
      await pumpChart(
        tester,
        title: 'AQI',
        points: [point()],
        metric: 'aqiValue',
        delta: -18.5,
      );

      // Assert
      expect(find.text('18.5%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('should render not-available when the chart has no comparison '
        'period', (tester) async {
      // Arrange / Act
      await pumpChart(
        tester,
        title: 'AQI',
        points: [point()],
        metric: 'aqiValue',
        delta: null,
      );

      // Assert
      expect(find.text('N/A'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsNothing);
      expect(find.byIcon(Icons.trending_down), findsNothing);
    });
  });
}