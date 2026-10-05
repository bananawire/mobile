import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/domain/model/valueobjects/aqi.valueobject.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';
import 'package:mobile/analytics/interfaces/widgets/aqi_gauge_card.dart';

import 'helpers/analytics_widget_harness.dart';

/// Every background fill colour painted by a [Container] in the tree, used to
/// assert the severity badge colour without depending on tree shape.
List<Color?> containerFillColours(WidgetTester tester) {
  return tester
      .widgetList<Container>(find.byType(Container))
      .map((container) => container.decoration)
      .whereType<BoxDecoration>()
      .map((decoration) => decoration.color)
      .toList();
}

void main() {
  Future<void> pumpGauge(
    WidgetTester tester, {
    required double? value,
    required String category,
    required double? delta,
    bool isSelected = false,
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      localizedAnalyticsApp(
        AqiGaugeCard(
          value: value,
          category: category,
          delta: delta,
          isSelected: isSelected,
          onTap: onTap ?? () {},
        ),
        width: 520,
      ),
    );
  }

  group('AqiGaugeCard', () {
    testWidgets('should render the gauge title, the reading and the upper '
        'cased category', (tester) async {
      // Arrange / Act
      await pumpGauge(tester, value: 42, category: 'Good', delta: null);

      // Assert
      expect(find.text('AIR QUALITY INDEX'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('GOOD'), findsOneWidget);
    });

    testWidgets('should render the reading of an AQI value object rounded to '
        'a whole number', (tester) async {
      // Arrange
      final aqi = Aqi(42.75, 'Moderate');

      // Act
      await pumpGauge(
        tester,
        value: aqi.value,
        category: aqi.category,
        delta: null,
      );

      // Assert
      expect(find.text('43'), findsOneWidget);
      expect(find.text('MODERATE'), findsOneWidget);
    });

    testWidgets('should render a placeholder reading and the no-measurements '
        'category when there is no data', (tester) async {
      // Arrange / Act
      await pumpGauge(
        tester,
        value: null,
        category: 'No measurements',
        delta: null,
      );

      // Assert
      expect(find.text('--'), findsOneWidget);
      expect(find.text('NO MEASUREMENTS'), findsOneWidget);
    });

    testWidgets('should render a rising delta with an up arrow', (tester) async {
      // Arrange / Act
      await pumpGauge(tester, value: 42, category: 'Good', delta: 4.25);

      // Assert
      expect(find.text('4.3%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('should render a falling delta with a down arrow',
        (tester) async {
      // Arrange / Act
      await pumpGauge(tester, value: 42, category: 'Good', delta: -18.5);

      // Assert
      expect(find.text('18.5%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('should render not-available when the gauge has no comparison '
        'period', (tester) async {
      // Arrange / Act
      await pumpGauge(tester, value: 42, category: 'Good', delta: null);

      // Assert
      expect(find.text('N/A'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsNothing);
      expect(find.byIcon(Icons.trending_down), findsNothing);
    });

    testWidgets('should paint the category badge with the severity colour of '
        'the reading', (tester) async {
      // Arrange / Act
      await pumpGauge(tester, value: 160, category: 'Unhealthy', delta: null);

      // Assert
      final fills = containerFillColours(tester);
      expect(fills, contains(kUnhealthyColor));
      expect(fills, isNot(contains(kGoodColor)));
    });

    testWidgets('should paint the category badge with the good colour for a '
        'clean reading', (tester) async {
      // Arrange / Act
      await pumpGauge(tester, value: 20, category: 'Good', delta: null);

      // Assert
      final fills = containerFillColours(tester);
      expect(fills, contains(kGoodColor));
      expect(fills, isNot(contains(kUnhealthyColor)));
    });

    testWidgets('should notify its tap handler when the gauge is tapped',
        (tester) async {
      // Arrange
      var taps = 0;
      await pumpGauge(
        tester,
        value: 42,
        category: 'Good',
        delta: null,
        onTap: () => taps++,
      );

      // Act
      await tester.tap(find.byType(AqiGaugeCard));
      await tester.pump();

      // Assert
      expect(taps, 1);
    });

    testWidgets('should render a selected gauge with the same labels',
        (tester) async {
      // Arrange / Act
      await pumpGauge(
        tester,
        value: 128,
        category: 'Unhealthy for Sensitive',
        delta: 1.5,
        isSelected: true,
      );

      // Assert
      expect(find.text('128'), findsOneWidget);
      expect(find.text('UNHEALTHY FOR SENSITIVE'), findsOneWidget);
      expect(find.text('1.5%'), findsOneWidget);
    });
  });
}