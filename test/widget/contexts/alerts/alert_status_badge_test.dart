import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/interfaces/widgets/alert_status_badge.dart';

import '../../../support/test_widget_harness.dart';

void main() {
  group('AlertStatusBadge Widget', () {
    testWidgets('should render ACTIVE text and green background when status is active', (tester) async {
      // Arrange
      await tester.pumpWidget(
        buildTestableWidget(
          const AlertStatusBadge(status: AlertStatus.active),
        ),
      );

      // Act & Assert
      expect(find.text('ACTIVE'), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF10B981)));
    });

    testWidgets('should render ACKNOWLEDGED text and amber background when status is acknowledged', (tester) async {
      // Arrange
      await tester.pumpWidget(
        buildTestableWidget(
          const AlertStatusBadge(status: AlertStatus.acknowledged),
        ),
      );

      // Act & Assert
      expect(find.text('ACKNOWLEDGED'), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFFF59E0B)));
    });

    testWidgets('should render RESOLVED text and gray background when status is resolved', (tester) async {
      // Arrange
      await tester.pumpWidget(
        buildTestableWidget(
          const AlertStatusBadge(status: AlertStatus.resolved),
        ),
      );

      // Act & Assert
      expect(find.text('RESOLVED'), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF6B7280)));
    });
  });
}
