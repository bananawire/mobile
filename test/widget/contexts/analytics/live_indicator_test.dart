import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/interfaces/widgets/live_indicator.dart';

import '../../../support/test_widget_harness.dart';

void main() {
  group('LiveIndicator Widget', () {
    testWidgets(
      'should render active state with animation and live label when active is true',
      (tester) async {
        // Arrange
        var tapped = false;
        await tester.pumpWidget(
          buildTestableWidget(
            LiveIndicator(active: true, onTap: () => tapped = true),
          ),
        );

        final liveFadeFinder = find.descendant(
          of: find.byType(LiveIndicator),
          matching: find.byType(FadeTransition),
        );

        // Act & Assert
        expect(find.text('LIVE'), findsOneWidget);
        expect(liveFadeFinder, findsOneWidget);

        // Test tap interaction
        await tester.tap(find.byType(LiveIndicator));
        await tester.pump();
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'should render inactive state without pulsing fade transition when active is false',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildTestableWidget(LiveIndicator(active: false, onTap: () {})),
        );

        final liveFadeFinder = find.descendant(
          of: find.byType(LiveIndicator),
          matching: find.byType(FadeTransition),
        );

        // Act & Assert
        expect(find.text('LIVE'), findsOneWidget);
        expect(liveFadeFinder, findsNothing);
      },
    );

    testWidgets(
      'should pulse dot opacity as animation runs when active is true',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildTestableWidget(LiveIndicator(active: true, onTap: () {})),
        );

        final liveFadeFinder = find.descendant(
          of: find.byType(LiveIndicator),
          matching: find.byType(FadeTransition),
        );
        final initialFade = tester.widget<FadeTransition>(liveFadeFinder);
        final initialOpacity = initialFade.opacity.value;

        // Act - advance animation timer
        await tester.pump(const Duration(milliseconds: 550));

        final midFade = tester.widget<FadeTransition>(liveFadeFinder);
        final midOpacity = midFade.opacity.value;

        // Assert opacity changed through animation
        expect(midOpacity, isNot(equals(initialOpacity)));
      },
    );
  });
}
