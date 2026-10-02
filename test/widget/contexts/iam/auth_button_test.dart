import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/interfaces/widgets/auth_button.dart';

import '../../../support/test_widget_harness.dart';

void main() {
  group('AuthButton', () {
    testWidgets('should render label text when not loading', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          const AuthButton(
            label: 'Sign In',
            isLoading: false,
          ),
        ),
      );

      // Assert
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should render CircularProgressIndicator and not label when isLoading is true', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          const AuthButton(
            label: 'Sign In',
            isLoading: true,
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
    });

    testWidgets('should trigger onPressed callback when tapped and not loading', (tester) async {
      // Arrange
      var wasPressed = false;
      await tester.pumpWidget(
        buildTestableWidget(
          AuthButton(
            label: 'Submit',
            isLoading: false,
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('should not trigger onPressed when isLoading is true', (tester) async {
      // Arrange
      var wasPressed = false;
      await tester.pumpWidget(
        buildTestableWidget(
          AuthButton(
            label: 'Submit',
            isLoading: true,
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(AuthButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isFalse);
    });

    testWidgets('should render icon when icon is provided and not loading', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          const AuthButton(
            label: 'Google Sign In',
            isLoading: false,
            icon: Icon(Icons.g_mobiledata),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
      expect(find.text('Google Sign In'), findsOneWidget);
    });

    testWidgets('should render ElevatedButton when isSecondary is false', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          const AuthButton(
            label: 'Primary Action',
            isLoading: false,
            isSecondary: false,
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('should render OutlinedButton when isSecondary is true', (tester) async {
      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          const AuthButton(
            label: 'Secondary Action',
            isLoading: false,
            isSecondary: true,
          ),
        ),
      );

      // Assert
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
