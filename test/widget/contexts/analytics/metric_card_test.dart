import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';
import 'package:mobile/analytics/interfaces/widgets/metric_card.dart';

import '../../../support/test_widget_harness.dart';

void main() {
  group('MetricCard Widget', () {
    testWidgets(
      'should render title, value, unit, and positive delta with trending up icon',
      (tester) async {
        // Arrange
        var tapped = false;
        await tester.pumpWidget(
          buildTestableWidget(
            MetricCard(
              title: 'CO2',
              value: 650.0,
              unit: 'ppm',
              delta: 4.5,
              statusColor: kGoodColor,
              isSelected: true,
              onTap: () => tapped = true,
            ),
          ),
        );

        // Assert
        expect(find.text('CO2'), findsOneWidget);
        expect(find.text('650.00'), findsOneWidget);
        expect(find.text('ppm'), findsOneWidget);
        expect(find.text('4.5%'), findsOneWidget);
        expect(find.byIcon(Icons.trending_up), findsOneWidget);

        // Act & Assert tap
        await tester.tap(find.byType(MetricCard));
        await tester.pump();
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'should render negative delta with trending down icon and red color',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildTestableWidget(
            MetricCard(
              title: 'PM2.5',
              value: 14.25,
              unit: 'µg/m³',
              delta: -2.3,
              statusColor: kModerateColor,
              isSelected: false,
              onTap: () {},
            ),
          ),
        );

        // Assert
        expect(find.text('PM2.5'), findsOneWidget);
        expect(find.text('14.25'), findsOneWidget);
        expect(find.text('µg/m³'), findsOneWidget);
        expect(find.text('2.3%'), findsOneWidget);
        expect(find.byIcon(Icons.trending_down), findsOneWidget);
      },
    );

    testWidgets('should render N/A and -- when delta and value are null', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildTestableWidget(
          MetricCard(
            title: 'HUMIDITY',
            value: null,
            unit: '%',
            delta: null,
            statusColor: kMutedColor,
            isSelected: false,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('--'), findsOneWidget);
      expect(find.text('N/A'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsNothing);
      expect(find.byIcon(Icons.trending_down), findsNothing);
    });

    testWidgets('should apply highlight border when isSelected is true', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildTestableWidget(
          MetricCard(
            title: 'TEMP',
            value: 23.0,
            unit: '°C',
            delta: 0.0,
            statusColor: kGoodColor,
            isSelected: true,
            onTap: () {},
          ),
        ),
      );

      // Act
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(MetricCard),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration as BoxDecoration;

      // Assert
      expect((decoration.border as Border).top.color, equals(kGoodColor));
    });
  });
}
