import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/interfaces/widgets/clair_name.dart';

import 'helpers/shared_widget_harness.dart';

void main() {
  /// The rendered [SvgPicture] of the brand mark.
  SvgPicture brandMark(WidgetTester tester) =>
      tester.widget<SvgPicture>(find.byType(SvgPicture));

  group('ClairName size', () {
    testWidgets('should render at its default size when nothing is configured', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(sharedTestApp(child: const ClairName()));

      // Act
      final picture = brandMark(tester);

      // Assert: the default height is 18 and the SVG aspect ratio is 138:18, so
      // the default width comes out at 138.
      expect(picture.height, 18.0);
      expect(picture.width, 138.0);
      expect(tester.getSize(find.byType(SvgPicture)), const Size(138, 18));
    });

    testWidgets(
      'should scale the width with the height when only height is given',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          sharedTestApp(child: const ClairName(height: 36)),
        );

        // Act
        final picture = brandMark(tester);

        // Assert: 36 * 138 / 18 = 276, the mark keeps its aspect ratio.
        expect(picture.height, 36.0);
        expect(picture.width, 276.0);
        expect(tester.getSize(find.byType(SvgPicture)), const Size(276, 36));
      },
    );

    testWidgets('should shrink the width with the height', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(sharedTestApp(child: const ClairName(height: 9)));

      // Act
      final picture = brandMark(tester);

      // Assert
      expect(picture.width, 69.0);
      expect(tester.getSize(find.byType(SvgPicture)), const Size(69, 9));
    });

    testWidgets('should honour an explicit width over the computed one', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        sharedTestApp(child: const ClairName(height: 18, width: 60)),
      );

      // Act
      final picture = brandMark(tester);

      // Assert: the explicit width wins over `height * 138 / 18`, so the mark
      // is deliberately stretched away from its 138:18 aspect ratio.
      expect(picture.width, 60.0);
      expect(picture.height, 18.0);
    });

    testWidgets('should keep an explicit width independent of the height', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        sharedTestApp(child: const ClairName(height: 40, width: 100)),
      );

      // Act
      final picture = brandMark(tester);

      // Assert
      expect(picture.width, 100.0);
      expect(picture.height, 40.0);
    });
  });

  group('ClairName colour', () {
    testWidgets('should tint the mark white by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(sharedTestApp(child: const ClairName()));

      // Act
      final picture = brandMark(tester);

      // Assert: the mark is authored white, so the default is a white tint.
      expect(
        picture.colorFilter,
        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    });

    testWidgets('should tint the mark with an explicit colour', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        sharedTestApp(child: const ClairName(color: Colors.amber)),
      );

      // Act
      final picture = brandMark(tester);

      // Assert
      expect(
        picture.colorFilter,
        const ColorFilter.mode(Colors.amber, BlendMode.srcIn),
      );
    });

    testWidgets('should apply no tint when the colour is null', (
      WidgetTester tester,
    ) async {
      // Arrange: an explicit null opts out of the colour filter.
      await tester.pumpWidget(
        sharedTestApp(child: const ClairName(color: null)),
      );

      // Act
      final picture = brandMark(tester);

      // Assert
      expect(picture.colorFilter, isNull);
    });
  });

  group('ClairName rendering', () {
    testWidgets('should render as an inline svg without loading an asset', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(sharedTestApp(child: const ClairName()));

      // Act
      final picture = brandMark(tester);

      // Assert: the brand mark ships as an SVG string, not a bundled asset, so
      // it paints in a widget test with no asset bundle configured.
      expect(picture, isA<SvgPicture>());
      expect(tester.takeException(), isNull);
      expect(find.byType(ClairName), findsOneWidget);
    });

    testWidgets('should sit inside an app bar title slot', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        sharedTestApp(child: AppBar(title: const ClairName(height: 18))),
      );

      // Act
      final picture = brandMark(tester);

      // Assert
      expect(find.byType(ClairName), findsOneWidget);
      expect(picture.width, 138.0);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(ClairName),
        ),
        findsOneWidget,
      );
    });
  });
}
