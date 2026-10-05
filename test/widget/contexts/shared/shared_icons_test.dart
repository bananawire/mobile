import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/interfaces/widgets/icons/air_quality_icon.dart';
import 'package:mobile/shared/interfaces/widgets/icons/alerts_icon.dart';
import 'package:mobile/shared/interfaces/widgets/icons/clair_device_icon.dart';
import 'package:mobile/shared/interfaces/widgets/icons/clair_icon.dart';
import 'package:mobile/shared/interfaces/widgets/icons/google_icon.dart';
import 'package:mobile/shared/interfaces/widgets/icons/space_devices_icon.dart';

import 'helpers/shared_widget_harness.dart';

/// Every icon in the shared context is an inline `SvgPicture.string`, so a
/// widget test can assert the geometry the widget asks for and the tint it
/// applies. Pixel content of an SVG path is not asserted: the markup is the
/// artwork, not behaviour.
void main() {
  /// The rendered [SvgPicture] of [child].
  SvgPicture pictureOf(WidgetTester tester, Widget child) {
    return tester.widget<SvgPicture>(
      find.descendant(
        of: find.byWidget(child),
        matching: find.byType(SvgPicture),
      ),
    );
  }

  /// The white tint every icon falls back to.
  const whiteTint = ColorFilter.mode(Colors.white, BlendMode.srcIn);

  group('AirQualityIcon', () {
    // The source SVG is 18x16, so the height follows size * 16 / 18.
    testWidgets('should keep its 18:16 aspect ratio at the default size', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = AirQualityIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 24.0);
      expect(picture.height, closeTo(24.0 * 16 / 18, 0.001));
    });

    testWidgets('should scale both axes with the requested size', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = AirQualityIcon(size: 48);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 48.0);
      expect(picture.height, closeTo(48.0 * 16 / 18, 0.001));
    });

    testWidgets('should tint the glyph white by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = AirQualityIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(pictureOf(tester, icon).colorFilter, whiteTint);
    });

    testWidgets('should apply an explicit tint', (WidgetTester tester) async {
      // Arrange
      const icon = AirQualityIcon(color: Colors.cyan);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(
        pictureOf(tester, icon).colorFilter,
        const ColorFilter.mode(Colors.cyan, BlendMode.srcIn),
      );
    });

    testWidgets('should apply no tint when the colour is null', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = AirQualityIcon(color: null);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(pictureOf(tester, icon).colorFilter, isNull);
    });
  });

  group('AlertsIcon', () {
    // The source SVG is 20x16, so the height follows size * 16 / 20.
    testWidgets('should keep its 20:16 aspect ratio at the default size', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = AlertsIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 24.0);
      expect(picture.height, closeTo(24.0 * 16 / 20, 0.001));
    });

    testWidgets('should scale both axes with the requested size', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = AlertsIcon(size: 60);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 60.0);
      expect(picture.height, closeTo(60.0 * 16 / 20, 0.001));
    });

    testWidgets('should tint the glyph white by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = AlertsIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(pictureOf(tester, icon).colorFilter, whiteTint);
    });

    testWidgets('should apply no tint when the colour is null', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = AlertsIcon(color: null);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(pictureOf(tester, icon).colorFilter, isNull);
    });
  });

  group('SpaceDevicesIcon', () {
    // The source SVG is 28x26, so the height follows size * 26 / 28.
    testWidgets('should keep its 28:26 aspect ratio at the default size', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = SpaceDevicesIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 24.0);
      expect(picture.height, closeTo(24.0 * 26 / 28, 0.001));
    });

    testWidgets('should scale both axes with the requested size', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = SpaceDevicesIcon(size: 40);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 40.0);
      expect(picture.height, closeTo(40.0 * 26 / 28, 0.001));
    });

    testWidgets('should tint the glyph white by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = SpaceDevicesIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(pictureOf(tester, icon).colorFilter, whiteTint);
    });

    testWidgets('should apply no tint when the colour is null', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = SpaceDevicesIcon(color: null);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(pictureOf(tester, icon).colorFilter, isNull);
    });
  });

  group('ClairIcon', () {
    // The source SVG is 492x286, so the height follows size * 286 / 492.
    testWidgets('should keep its 492:286 aspect ratio at the default size', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = ClairIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 24.0);
      expect(picture.height, closeTo(24.0 * 286 / 492, 0.001));
    });

    testWidgets('should scale both axes with the requested size', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = ClairIcon(size: 98.4);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 98.4);
      expect(picture.height, closeTo(98.4 * 286 / 492, 0.001));
    });

    testWidgets('should tint the mark white by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = ClairIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(pictureOf(tester, icon).colorFilter, whiteTint);
    });

    testWidgets('should apply no tint when the colour is null', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = ClairIcon(color: null);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(pictureOf(tester, icon).colorFilter, isNull);
    });
  });

  group('ClairDeviceIcon', () {
    // The source SVG is square, 114x114, so both axes follow size.
    testWidgets('should render square at the default size', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = ClairDeviceIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 24.0);
      expect(picture.height, 24.0);
    });

    testWidgets('should scale both axes equally', (WidgetTester tester) async {
      // Arrange
      const icon = ClairDeviceIcon(size: 72);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 72.0);
      expect(picture.height, 72.0);
    });

    testWidgets('should tint the mark white by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = ClairDeviceIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(pictureOf(tester, icon).colorFilter, whiteTint);
    });

    testWidgets('should apply no tint when the colour is null', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = ClairDeviceIcon(color: null);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(pictureOf(tester, icon).colorFilter, isNull);
    });
  });

  group('GoogleIcon', () {
    // The source SVG is square, 17x17, so both axes follow size.
    testWidgets('should render square at the default size', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = GoogleIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 24.0);
      expect(picture.height, 24.0);
    });

    testWidgets('should scale both axes equally', (WidgetTester tester) async {
      // Arrange
      const icon = GoogleIcon(size: 17);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      final picture = pictureOf(tester, icon);
      expect(picture.width, 17.0);
      expect(picture.height, 17.0);
    });

    testWidgets('should tint the mark white by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      const icon = GoogleIcon();

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(pictureOf(tester, icon).colorFilter, whiteTint);
    });

    testWidgets('should apply an explicit tint', (WidgetTester tester) async {
      // Arrange
      const icon = GoogleIcon(color: Colors.black);

      // Act
      await tester.pumpWidget(sharedTestApp(child: icon));

      // Assert
      expect(
        pictureOf(tester, icon).colorFilter,
        const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      );
    });
  });

  group('shared icons asset independence', () {
    testWidgets('should paint every icon without an asset bundle', (
      WidgetTester tester,
    ) async {
      // Arrange: no SVG file is declared in pubspec, so the suite would fail to
      // load one if any icon reached for the asset bundle.
      await tester.pumpWidget(
        sharedTestApp(
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AirQualityIcon(),
              AlertsIcon(),
              SpaceDevicesIcon(),
              ClairIcon(),
              ClairDeviceIcon(),
              GoogleIcon(),
            ],
          ),
        ),
      );

      // Act
      await settle(tester);

      // Assert
      expect(find.byType(SvgPicture), findsNWidgets(6));
      expect(tester.takeException(), isNull);
    });
  });
}
