import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/interfaces/widgets/auth_button.dart';

import 'helpers/auth_widget_harness.dart';

void main() {
  group('AuthButton', () {
    testWidgets('should show its label when it is not loading', (tester) async {
      // Arrange
      const label = 'Sign in';

      // Act
      await tester.pumpWidget(
        localizedApp(AuthButton(label: label, isLoading: false)),
      );

      // Assert
      expect(find.text(label), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should invoke the callback when it is pressed', (tester) async {
      // Arrange
      var presses = 0;
      const label = 'Sign in';

      // Act
      await tester.pumpWidget(
        localizedApp(
          AuthButton(label: label, isLoading: false, onPressed: () => presses++),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(presses, 1);
    });

    testWidgets('should be disabled when no callback is provided', (tester) async {
      // Arrange
      const label = 'Sign in';

      // Act
      await tester.pumpWidget(
        localizedApp(const AuthButton(label: label, isLoading: false)),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(tester.widget<Text>(find.text(label)).data, label);
    });

    testWidgets(
      'should show a spinner and block presses while it is loading',
      (tester) async {
        // Arrange
        var presses = 0;
        const label = 'Sign in';

        // Act
        await tester.pumpWidget(
          localizedApp(
            AuthButton(label: label, isLoading: true, onPressed: () => presses++),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text(label), findsNothing);

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);

        // Act
        await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
        await tester.pump();

        // Assert
        expect(presses, 0);
      },
    );

    testWidgets('should render an outlined button when it is secondary', (tester) async {
      // Arrange
      var presses = 0;
      const label = 'Continue with Google';

      // Act
      await tester.pumpWidget(
        localizedApp(
          AuthButton(
            label: label,
            isLoading: false,
            isSecondary: true,
            onPressed: () => presses++,
          ),
        ),
      );

      // Assert
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);

      // Act
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      // Assert
      expect(presses, 1);
    });

    testWidgets(
      'should block presses of a secondary button while it is loading',
      (tester) async {
        // Arrange
        var presses = 0;
        const label = 'Continue with Google';

        // Act
        await tester.pumpWidget(
          localizedApp(
            AuthButton(
              label: label,
              isLoading: true,
              isSecondary: true,
              onPressed: () => presses++,
            ),
          ),
        );

        // Assert
        final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
        expect(button.onPressed, isNull);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Act
        await tester.tap(find.byType(OutlinedButton), warnIfMissed: false);
        await tester.pump();

        // Assert
        expect(presses, 0);
      },
    );

    testWidgets('should render the leading icon next to the label', (tester) async {
      // Arrange
      const label = 'Continue with Google';

      // Act
      await tester.pumpWidget(
        localizedApp(
          const AuthButton(
            label: label,
            isLoading: false,
            icon: Icon(Icons.g_mobiledata),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
      expect(find.text(label), findsOneWidget);
    });
  });
}