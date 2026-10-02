import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';
import 'package:mobile/analytics/interfaces/widgets/aqi_gauge_card.dart';

import '../../../support/test_widget_harness.dart';

void main() {
  group('AqiGaugeCard Widget', () {
    testWidgets(
      'should render AQI title, uppercase category, rounded value, and positive delta',
      (tester) async {
        // Arrange
        var tapped = false;
        await tester.pumpWidget(
          buildTestableWidget(
            AqiGaugeCard(
              value: 42.6,
              category: 'Good',
              delta: 3.5,
              isSelected: true,
              onTap: () => tapped = true,
            ),
          ),
        );

        // Assert
        expect(find.text('AIR QUALITY INDEX'), findsOneWidget);
        expect(find.text('GOOD'), findsOneWidget);
        expect(find.text('43'), findsOneWidget);
        expect(find.text('3.5%'), findsOneWidget);
        expect(find.byIcon(Icons.trending_up), findsOneWidget);

        // Act & Assert tap
        await tester.tap(find.byType(AqiGaugeCard));
        await tester.pump();
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'should render "--" when value is null and "N/A" when delta is null',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildTestableWidget(
            AqiGaugeCard(
              value: null,
              category: 'No measurements',
              delta: null,
              isSelected: false,
              onTap: () {},
            ),
          ),
        );

        // Assert
        expect(find.text('--'), findsOneWidget);
        expect(find.text('NO MEASUREMENTS'), findsOneWidget);
        expect(find.text('N/A'), findsOneWidget);
        expect(find.byIcon(Icons.trending_up), findsNothing);
        expect(find.byIcon(Icons.trending_down), findsNothing);
      },
    );

    testWidgets('should render trending down icon when delta is negative', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildTestableWidget(
          AqiGaugeCard(
            value: 78.0,
            category: 'Moderate',
            delta: -5.2,
            isSelected: false,
            onTap: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('78'), findsOneWidget);
      expect(find.text('MODERATE'), findsOneWidget);
      expect(find.text('5.2%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets(
      'should render gauge custom painter and highlight border when selected',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildTestableWidget(
            AqiGaugeCard(
              value: 120.0,
              category: 'Unhealthy for Sensitive',
              delta: 1.0,
              isSelected: true,
              onTap: () {},
            ),
          ),
        );

        // Assert CustomPaint exists
        expect(find.byType(CustomPaint), findsWidgets);

        // Check border
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(AqiGaugeCard),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect((decoration.border as Border).top.color, equals(kGoodColor));
      },
    );
  });
}
