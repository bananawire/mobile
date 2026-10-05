import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/interfaces/widgets/live_indicator.dart';

import 'helpers/analytics_widget_harness.dart';

/// The LIVE pill drives a repeating animation, so every assertion below uses
/// bounded pumps instead of `pumpAndSettle` (which would never settle).
void main() {
  Future<void> pumpIndicator(
    WidgetTester tester, {
    required bool active,
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      localizedAnalyticsApp(
        LiveIndicator(active: active, onTap: onTap ?? () {}),
      ),
    );
    await tester.pump();
  }

  group('LiveIndicator', () {
    testWidgets('should render the localized live label', (tester) async {
      // Arrange / Act
      await pumpIndicator(tester, active: true);

      // Assert
      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('should render the live label when inactive as well',
        (tester) async {
      // Arrange / Act
      await pumpIndicator(tester, active: false);

      // Assert
      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('should pulse the dot while active', (tester) async {
      // Arrange
      await pumpIndicator(tester, active: true);

      // Act
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 550));

      // Assert
      expect(
        find.descendant(
          of: find.byType(LiveIndicator),
          matching: find.byType(FadeTransition),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should not pulse the dot while inactive', (tester) async {
      // Arrange
      await pumpIndicator(tester, active: false);

      // Act
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 550));

      // Assert
      expect(
        find.descendant(
          of: find.byType(LiveIndicator),
          matching: find.byType(FadeTransition),
        ),
        findsNothing,
      );
    });

    testWidgets('should notify its tap handler when the pill is tapped',
        (tester) async {
      // Arrange
      var taps = 0;
      await pumpIndicator(tester, active: true, onTap: () => taps++);

      // Act
      await tester.tap(find.byType(LiveIndicator));
      await tester.pump(const Duration(milliseconds: 200));

      // Assert
      expect(taps, 1);
    });

    testWidgets('should keep animating without throwing after several '
        'animation frames', (tester) async {
      // Arrange
      await pumpIndicator(tester, active: true);

      // Act
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 220));
      }

      // Assert
      expect(tester.takeException(), isNull);
      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('should stop the animation when it leaves the tree',
        (tester) async {
      // Arrange
      await pumpIndicator(tester, active: true);

      // Act
      await tester.pumpWidget(
        localizedAnalyticsApp(const SizedBox.shrink()),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Assert
      expect(tester.takeException(), isNull);
      expect(find.byType(LiveIndicator), findsNothing);
    });
  });
}