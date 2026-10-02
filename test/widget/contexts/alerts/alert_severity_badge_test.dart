import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/interfaces/widgets/alert_severity_badge.dart';

import '../../../support/test_widget_harness.dart';

void main() {
  group('AlertSeverityBadge Widget', () {
    testWidgets(
      'should render CRITICAL text and red styling when severity is critical',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildTestableWidget(
            const AlertSeverityBadge(severity: AlertSeverity.critical),
          ),
        );

        // Act & Assert
        final textFinder = find.text('CRITICAL');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, equals(const Color(0xFFEF4444)));

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(
          decoration.color,
          equals(const Color.fromRGBO(239, 68, 68, 0.15)),
        );
        expect(
          decoration.border?.top.color,
          equals(const Color.fromRGBO(239, 68, 68, 0.3)),
        );
      },
    );

    testWidgets(
      'should render WARNING text and amber styling when severity is warning',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildTestableWidget(
            const AlertSeverityBadge(severity: AlertSeverity.warning),
          ),
        );

        // Act & Assert
        final textFinder = find.text('WARNING');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, equals(const Color(0xFFF59E0B)));

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(
          decoration.color,
          equals(const Color.fromRGBO(245, 158, 11, 0.15)),
        );
        expect(
          decoration.border?.top.color,
          equals(const Color.fromRGBO(245, 158, 11, 0.3)),
        );
      },
    );

    testWidgets(
      'should render LOW text and green styling when severity is low',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildTestableWidget(
            const AlertSeverityBadge(severity: AlertSeverity.low),
          ),
        );

        // Act & Assert
        final textFinder = find.text('LOW');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, equals(const Color(0xFF10B981)));

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(
          decoration.color,
          equals(const Color.fromRGBO(16, 185, 129, 0.15)),
        );
        expect(
          decoration.border?.top.color,
          equals(const Color.fromRGBO(16, 185, 129, 0.3)),
        );
      },
    );
  });
}
