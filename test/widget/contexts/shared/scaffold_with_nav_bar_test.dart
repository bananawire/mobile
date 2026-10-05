import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/l10n/generated/app_localizations_es.dart';
import 'package:mobile/shared/interfaces/widgets/icons/alerts_icon.dart';
import 'package:mobile/shared/interfaces/widgets/icons/air_quality_icon.dart';
import 'package:mobile/shared/interfaces/widgets/icons/space_devices_icon.dart';
import 'package:mobile/shared/interfaces/widgets/scaffold_with_nav_bar.dart';

import 'helpers/shared_widget_harness.dart';

void main() {
  group('ScaffoldWithNavBar destinations', () {
    testWidgets('should render the three localized destination labels', (
      WidgetTester tester,
    ) async {
      // Arrange
      final router = sharedShellRouter();

      // Act
      await pumpSharedRouter(tester, router);

      // Assert
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Spaces'), findsOneWidget);
      addTearDown(router.dispose);
    });

    testWidgets('should render one icon per destination', (
      WidgetTester tester,
    ) async {
      // Arrange
      final router = sharedShellRouter();

      // Act
      await pumpSharedRouter(tester, router);

      // Assert
      expect(find.byType(AirQualityIcon), findsOneWidget);
      expect(find.byType(AlertsIcon), findsOneWidget);
      expect(find.byType(SpaceDevicesIcon), findsOneWidget);
      addTearDown(router.dispose);
    });

    testWidgets('should render the routed child as the shell body', (
      WidgetTester tester,
    ) async {
      // Arrange
      final router = sharedShellRouter(initialLocation: '/alerts');

      // Act
      await pumpSharedRouter(tester, router);

      // Assert
      expect(find.byType(ScaffoldWithNavBar), findsOneWidget);
      expect(find.text('Alerts page'), findsOneWidget);
      addTearDown(router.dispose);
    });

    testWidgets('should expose each destination label to screen readers', (
      WidgetTester tester,
    ) async {
      // Arrange
      final router = sharedShellRouter();
      final handle = tester.ensureSemantics();

      // Act
      await pumpSharedRouter(tester, router);

      // Assert
      expect(find.bySemanticsLabel('Analytics'), findsOneWidget);
      expect(find.bySemanticsLabel('Alerts'), findsOneWidget);
      expect(find.bySemanticsLabel('Spaces'), findsOneWidget);
      handle.dispose();
      addTearDown(router.dispose);
    });
  });

  group('ScaffoldWithNavBar selection', () {
    /// The color of the [Text] label of the destination called [label], which
    /// is how the shell marks the selected destination.
    Color labelColor(WidgetTester tester, String label) {
      final text = tester.widget<Text>(find.text(label));
      return text.style!.color!;
    }

    /// The font weight of the label of the destination called [label].
    FontWeight labelWeight(WidgetTester tester, String label) {
      final text = tester.widget<Text>(find.text(label));
      return text.style!.fontWeight!;
    }

    testWidgets(
      'should highlight analytics as selected on the analytics route',
      (WidgetTester tester) async {
        // Arrange
        final router = sharedShellRouter(initialLocation: '/analytics');

        // Act
        await pumpSharedRouter(tester, router);

        // Assert
        expect(labelColor(tester, 'Analytics'), Colors.white);
        expect(labelWeight(tester, 'Analytics'), FontWeight.w600);
        expect(labelColor(tester, 'Alerts'), Colors.white54);
        expect(labelWeight(tester, 'Alerts'), FontWeight.normal);
        addTearDown(router.dispose);
      },
    );

    testWidgets('should highlight alerts as selected on the alerts route', (
      WidgetTester tester,
    ) async {
      // Arrange
      final router = sharedShellRouter(initialLocation: '/alerts');

      // Act
      await pumpSharedRouter(tester, router);

      // Assert
      expect(labelColor(tester, 'Alerts'), Colors.white);
      expect(labelColor(tester, 'Analytics'), Colors.white54);
      expect(labelColor(tester, 'Spaces'), Colors.white54);
      addTearDown(router.dispose);
    });

    testWidgets('should highlight spaces as selected on the spaces route', (
      WidgetTester tester,
    ) async {
      // Arrange
      final router = sharedShellRouter(initialLocation: '/spaces');

      // Act
      await pumpSharedRouter(tester, router);

      // Assert
      expect(labelColor(tester, 'Spaces'), Colors.white);
      expect(labelColor(tester, 'Analytics'), Colors.white54);
      addTearDown(router.dispose);
    });

    testWidgets('should keep spaces highlighted on a nested space route', (
      WidgetTester tester,
    ) async {
      // Arrange
      final router = sharedShellRouter(initialLocation: '/spaces/org-1');

      // Act
      await pumpSharedRouter(tester, router);

      // Assert: the shell matches on the `/spaces` prefix, so a nested route
      // keeps the spaces destination selected.
      expect(labelColor(tester, 'Spaces'), Colors.white);
      expect(find.text('Space org-1'), findsOneWidget);
      addTearDown(router.dispose);
    });

    testWidgets('should fall back to analytics for an unmapped route', (
      WidgetTester tester,
    ) async {
      // Arrange: the shell is mounted on `/home`, which is not one of the three
      // prefixes the shell maps.
      final router = sharedUnknownRouteRouter();

      // Act
      await pumpSharedRouter(tester, router);

      // Assert
      expect(labelColor(tester, 'Analytics'), Colors.white);
      expect(labelWeight(tester, 'Analytics'), FontWeight.w600);
      expect(labelColor(tester, 'Alerts'), Colors.white54);
      expect(labelColor(tester, 'Spaces'), Colors.white54);
      addTearDown(router.dispose);
    });
  });

  group('ScaffoldWithNavBar navigation', () {
    testWidgets(
      'should route to analytics when the analytics destination is tapped',
      (WidgetTester tester) async {
        // Arrange
        final router = sharedShellRouter(initialLocation: '/alerts');

        // Act
        await pumpSharedRouter(tester, router);
        await tester.tap(find.text('Analytics'));
        await settleNavigation(tester);

        // Assert
        expect(find.text('Analytics page'), findsOneWidget);
        addTearDown(router.dispose);
      },
    );

    testWidgets(
      'should route to alerts when the alerts destination is tapped',
      (WidgetTester tester) async {
        // Arrange
        final router = sharedShellRouter(initialLocation: '/analytics');

        // Act
        await pumpSharedRouter(tester, router);
        await tester.tap(find.text('Alerts'));
        await settleNavigation(tester);

        // Assert
        expect(find.text('Alerts page'), findsOneWidget);
        addTearDown(router.dispose);
      },
    );

    testWidgets(
      'should route to spaces when the spaces destination is tapped',
      (WidgetTester tester) async {
        // Arrange
        final router = sharedShellRouter(initialLocation: '/analytics');

        // Act
        await pumpSharedRouter(tester, router);
        await tester.tap(find.text('Spaces'));
        await settleNavigation(tester);

        // Assert
        expect(find.text('Spaces page'), findsOneWidget);
        addTearDown(router.dispose);
      },
    );

    testWidgets(
      'should move the selection highlight to the tapped destination',
      (WidgetTester tester) async {
        // Arrange
        final router = sharedShellRouter(initialLocation: '/analytics');

        // Act
        await pumpSharedRouter(tester, router);
        await tester.tap(find.text('Alerts'));
        await settleNavigation(tester);

        // Assert
        final alertsLabel = tester.widget<Text>(find.text('Alerts'));
        final analyticsLabel = tester.widget<Text>(find.text('Analytics'));
        expect(alertsLabel.style!.color, Colors.white);
        expect(alertsLabel.style!.fontWeight, FontWeight.w600);
        expect(analyticsLabel.style!.color, Colors.white54);
        addTearDown(router.dispose);
      },
    );

    testWidgets(
      'should stay on the current page when the selected destination is tapped',
      (WidgetTester tester) async {
        // Arrange
        final router = sharedShellRouter(initialLocation: '/alerts');

        // Act
        await pumpSharedRouter(tester, router);
        await tester.tap(find.text('Alerts'));
        await settleNavigation(tester);

        // Assert
        expect(find.text('Alerts page'), findsOneWidget);
        addTearDown(router.dispose);
      },
    );
  });

  group('ScaffoldWithNavBar localization', () {
    testWidgets('should render spanish labels when the app locale is spanish', (
      WidgetTester tester,
    ) async {
      // Arrange: the shell takes its labels straight from the localizations.
      final router = sharedShellRouter();
      final spanishLabels = AppLocalizationsEs().nav_analytics;
      expect(spanishLabels, isNot('Analytics'));

      // Act
      await pumpSharedRouter(tester, router, locale: const Locale('es'));

      // Assert
      expect(find.text(spanishLabels), findsOneWidget);
      addTearDown(router.dispose);
    });
  });
}
