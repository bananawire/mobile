import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_severity.valueobject.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert_status.valueobject.dart';
import 'package:mobile/alerts/interfaces/widgets/alert_severity_badge.dart';
import 'package:mobile/alerts/interfaces/widgets/alert_status_badge.dart';

import 'alerts_widget_harness.dart';

void main() {
  /// Reads the color the badge applies to its label text.
  Color labelColorOf(WidgetTester tester, String label) {
    final text = tester.widget<Text>(find.text(label));
    return text.style!.color!;
  }

  /// Reads the color the badge paints as its background.
  Color backgroundOf(WidgetTester tester, String label) {
    final container = tester.widget<Container>(
      find
          .ancestor(
            of: find.text(label),
            matching: find.byType(Container),
          )
          .first,
    );
    return (container.decoration! as BoxDecoration).color!;
  }

  group('AlertSeverityBadge', () {
    testWidgets('should display the upper case wire code of the critical '
        'severity', (WidgetTester tester) async {
      // Arrange
      const severity = AlertSeverity.critical;

      // Act
      await tester.pumpWidget(
        alertsTestApp(child: const AlertSeverityBadge(severity: severity)),
      );

      // Assert
      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('WARNING'), findsNothing);
      expect(find.text('LOW'), findsNothing);
    });

    testWidgets('should display the upper case wire code of the warning '
        'severity', (WidgetTester tester) async {
      // Arrange
      const severity = AlertSeverity.warning;

      // Act
      await tester.pumpWidget(
        alertsTestApp(child: const AlertSeverityBadge(severity: severity)),
      );

      // Assert
      expect(find.text('WARNING'), findsOneWidget);
    });

    testWidgets('should display the upper case wire code of the low severity',
        (WidgetTester tester) async {
      // Arrange
      const severity = AlertSeverity.low;

      // Act
      await tester.pumpWidget(
        alertsTestApp(child: const AlertSeverityBadge(severity: severity)),
      );

      // Assert
      expect(find.text('LOW'), findsOneWidget);
    });

    testWidgets('should paint the label red when the severity is critical',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertSeverityBadge(severity: AlertSeverity.critical),
        ),
      );

      // Assert
      expect(labelColorOf(tester, 'CRITICAL'), const Color(0xFFEF4444));
      expect(
        backgroundOf(tester, 'CRITICAL'),
        const Color.fromRGBO(239, 68, 68, 0.15),
      );
    });

    testWidgets('should paint the label amber when the severity is warning',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertSeverityBadge(severity: AlertSeverity.warning),
        ),
      );

      // Assert
      expect(labelColorOf(tester, 'WARNING'), const Color(0xFFF59E0B));
    });

    testWidgets('should paint the label green when the severity is low',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertSeverityBadge(severity: AlertSeverity.low),
        ),
      );

      // Assert
      expect(labelColorOf(tester, 'LOW'), const Color(0xFF10B981));
    });

    testWidgets('should rebuild the badge when the severity changes',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertSeverityBadge(severity: AlertSeverity.low),
        ),
      );
      expect(find.text('LOW'), findsOneWidget);

      // Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertSeverityBadge(severity: AlertSeverity.critical),
        ),
      );

      // Assert
      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('LOW'), findsNothing);
    });
  });

  group('AlertStatusBadge', () {
    testWidgets('should display the upper case wire code of the active status',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertStatusBadge(status: AlertStatus.active),
        ),
      );

      // Assert
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('should display the upper case wire code of the acknowledged '
        'status', (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertStatusBadge(status: AlertStatus.acknowledged),
        ),
      );

      // Assert
      expect(find.text('ACKNOWLEDGED'), findsOneWidget);
    });

    testWidgets('should display the upper case wire code of the resolved '
        'status', (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertStatusBadge(status: AlertStatus.resolved),
        ),
      );

      // Assert
      expect(find.text('RESOLVED'), findsOneWidget);
    });

    testWidgets('should fill the badge green when the status is active',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertStatusBadge(status: AlertStatus.active),
        ),
      );

      // Assert
      expect(backgroundOf(tester, 'ACTIVE'), const Color(0xFF10B981));
    });

    testWidgets('should fill the badge amber when the status is acknowledged',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertStatusBadge(status: AlertStatus.acknowledged),
        ),
      );

      // Assert
      expect(backgroundOf(tester, 'ACKNOWLEDGED'), const Color(0xFFF59E0B));
    });

    testWidgets('should fill the badge grey when the status is resolved',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: const AlertStatusBadge(status: AlertStatus.resolved),
        ),
      );

      // Assert
      expect(backgroundOf(tester, 'RESOLVED'), const Color(0xFF6B7280));
    });

    testWidgets('should render the label in white for every status',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        alertsTestApp(
          child: const Column(
            children: [
              AlertStatusBadge(status: AlertStatus.active),
              AlertStatusBadge(status: AlertStatus.acknowledged),
              AlertStatusBadge(status: AlertStatus.resolved),
            ],
          ),
        ),
      );

      // Assert
      expect(labelColorOf(tester, 'ACTIVE'), Colors.white);
      expect(labelColorOf(tester, 'ACKNOWLEDGED'), Colors.white);
      expect(labelColorOf(tester, 'RESOLVED'), Colors.white);
    });
  });
}