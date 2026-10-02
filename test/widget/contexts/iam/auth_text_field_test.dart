import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/interfaces/widgets/auth_text_field.dart';

import '../../../support/test_widget_harness.dart';

void main() {
  group('AuthTextField', () {
    testWidgets('should render label and hint text', (tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          AuthTextField(
            controller: controller,
            label: 'Email Address',
            hint: 'Enter your email',
          ),
        ),
      );

      // Assert
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('should update controller when text is entered', (tester) async {
      // Arrange
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildTestableWidget(
          AuthTextField(
            controller: controller,
            label: 'Email',
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextFormField), 'user@example.com');
      await tester.pump();

      // Assert
      expect(controller.text, equals('user@example.com'));
    });

    testWidgets('should obscure text when obscureText is true', (tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          AuthTextField(
            controller: controller,
            label: 'Password',
            obscureText: true,
          ),
        ),
      );

      // Assert
      final editableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(editableText.obscureText, isTrue);
    });

    testWidgets('should not obscure text when obscureText is false', (tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          AuthTextField(
            controller: controller,
            label: 'Username',
            obscureText: false,
          ),
        ),
      );

      // Assert
      final editableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(editableText.obscureText, isFalse);
    });

    testWidgets('should render prefix and suffix icons when provided', (tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        buildTestableWidget(
          AuthTextField(
            controller: controller,
            label: 'Search',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: const Icon(Icons.clear),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should display validation error message when validator returns an error', (tester) async {
      // Arrange
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestableWidget(
          Form(
            key: formKey,
            child: AuthTextField(
              controller: controller,
              label: 'Required Field',
              validator: (value) => (value == null || value.isEmpty) ? 'Field is required' : null,
            ),
          ),
        ),
      );

      // Act
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Field is required'), findsOneWidget);
    });
  });
}
