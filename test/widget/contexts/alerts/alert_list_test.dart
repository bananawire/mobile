import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';
import 'package:mobile/alerts/interfaces/widgets/alert_list.dart';

import 'alerts_widget_harness.dart';

void main() {
  group('AlertList empty state', () {
    testWidgets('should show the empty message when no alerts are provided',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(child: AlertList(onViewModeChanged: (_) {})),
      );

      // Assert
      expect(find.text('No alerts'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off), findsOneWidget);
    });

    testWidgets('should show the empty message when the alert list is empty',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertList(alerts: <Alert>[], onViewModeChanged: (_) {}),
        ),
      );

      // Assert
      expect(find.text('No alerts'), findsOneWidget);
    });
  });

  group('AlertList loading state', () {
    testWidgets('should show the loading message and a spinner while alerts are '
        'being fetched', (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertList(loading: true, onViewModeChanged: (_) {}),
        ),
      );

      // Assert
      expect(find.text('Loading alerts...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should win over the error message when both are present',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertList(
            loading: true,
            error: 'Space not found',
            onViewModeChanged: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.text('Loading alerts...'), findsOneWidget);
      expect(find.text('Space not found'), findsNothing);
    });
  });

  group('AlertList error state', () {
    testWidgets('should show the error message instead of the empty message',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertList(error: 'Alerts service is down', onViewModeChanged: (_) {}),
        ),
      );

      // Assert
      expect(find.text('Alerts service is down'), findsOneWidget);
      expect(find.text('No alerts'), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should render the alerts once the error is cleared',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertList(error: 'Alerts service is down', onViewModeChanged: (_) {}),
        ),
      );

      // Act
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertList(
            alerts: <Alert>[buildTestAlert()],
            onViewModeChanged: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.text('Alerts service is down'), findsNothing);
      expect(find.text('PM2.5 above threshold'), findsOneWidget);
    });
  });

  group('AlertList content', () {
    testWidgets('should render one card per alert in list view mode',
        (WidgetTester tester) async {
      // Arrange
      final alerts = <Alert>[
        buildTestAlert(id: 'alert-1', message: 'First alert'),
        buildTestAlert(id: 'alert-2', message: 'Second alert'),
      ];

      // Act
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertList(
            alerts: alerts,
            viewMode: AlertViewMode.list,
            onViewModeChanged: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.text('First alert'), findsOneWidget);
      expect(find.text('Second alert'), findsOneWidget);
    });

    testWidgets('should render the cards in grid view mode as well',
        (WidgetTester tester) async {
      // Arrange
      final alerts = <Alert>[buildTestAlert(message: 'Grid alert')];

      // Act
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertList(
            alerts: alerts,
            viewMode: AlertViewMode.grid,
            onViewModeChanged: (_) {},
          ),
        ),
      );

      // Assert
      expect(find.text('Grid alert'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should report the requested view mode when the grid toggle is '
        'tapped', (WidgetTester tester) async {
      // Arrange
      AlertViewMode? requestedMode;
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertList(
            alerts: <Alert>[buildTestAlert()],
            viewMode: AlertViewMode.list,
            onViewModeChanged: (mode) => requestedMode = mode,
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pump();

      // Assert
      expect(requestedMode, AlertViewMode.grid);
    });

    testWidgets('should report the requested view mode when the list toggle is '
        'tapped', (WidgetTester tester) async {
      // Arrange
      AlertViewMode? requestedMode;
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertList(
            alerts: <Alert>[buildTestAlert()],
            viewMode: AlertViewMode.grid,
            onViewModeChanged: (mode) => requestedMode = mode,
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.view_list));
      await tester.pump();

      // Assert
      expect(requestedMode, AlertViewMode.list);
    });

    testWidgets('should highlight the toggle of the active view mode',
        (WidgetTester tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        alertsTestApp(
          child: AlertList(
            alerts: <Alert>[buildTestAlert()],
            viewMode: AlertViewMode.grid,
            onViewModeChanged: (_) {},
          ),
        ),
      );

      // Assert
      final gridIcon = tester.widget<Icon>(find.byIcon(Icons.grid_view));
      expect(gridIcon.color, Colors.white);
      final listIcon = tester.widget<Icon>(find.byIcon(Icons.view_list));
      expect(listIcon.color, const Color(0xFF9CA3AF));
    });
  });
}