import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/analytics/interfaces/rest/transform/analytics_presentation.dart';

import 'helpers/analytics_widget_harness.dart';

/// Renders [formatUpdateTime] with its own [BuildContext] so the localization
/// lookup happens inside a localized [MaterialApp].
class _UpdateTimeLabel extends StatelessWidget {
  final int secondsSinceUpdate;

  const _UpdateTimeLabel(this.secondsSinceUpdate);

  @override
  Widget build(BuildContext context) {
    return Text(formatUpdateTime(context, secondsSinceUpdate));
  }
}

/// Covers the presentation helpers that need a [BuildContext] because they
/// resolve their wording through the localization delegates.
void main() {
  Future<void> pumpLabel(
    WidgetTester tester,
    int secondsSinceUpdate,
  ) async {
    await tester.pumpWidget(
      localizedAnalyticsApp(_UpdateTimeLabel(secondsSinceUpdate)),
    );
  }

  group('formatUpdateTime', () {
    testWidgets('should render just now while the snapshot is younger than '
        'five seconds', (tester) async {
      // Arrange / Act
      await pumpLabel(tester, 0);

      // Assert
      expect(find.text('Just now'), findsOneWidget);
    });

    testWidgets('should render just now at the fourth second',
        (tester) async {
      // Arrange / Act
      await pumpLabel(tester, 4);

      // Assert
      expect(find.text('Just now'), findsOneWidget);
    });

    testWidgets('should render the elapsed seconds from the fifth second',
        (tester) async {
      // Arrange / Act
      await pumpLabel(tester, 5);

      // Assert
      expect(find.text('5 seconds ago'), findsOneWidget);
      expect(find.text('Just now'), findsNothing);
    });

    testWidgets('should render the elapsed seconds for a stale snapshot',
        (tester) async {
      // Arrange / Act
      await pumpLabel(tester, 42);

      // Assert
      expect(find.text('42 seconds ago'), findsOneWidget);
    });
  });
}