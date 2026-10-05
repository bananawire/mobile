import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/iam/interfaces/widgets/auth_text_field.dart';

import 'helpers/auth_widget_harness.dart';

void main() {
  group('AuthTextField', () {
    testWidgets('should show its label as the field decoration label', (tester) async {
      // Arrange
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      const label = 'Email';

      // Act
      await tester.pumpWidget(
        localizedApp(AuthTextField(controller: controller, label: label)),
      );

      // Assert
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.labelText, label);
    });

    testWidgets('should expose the entered text through its controller', (tester) async {
      // Arrange
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      const typed = 'ada.lovelace@example.com';

      // Act
      await tester.pumpWidget(
        localizedApp(
          AuthTextField(controller: controller, label: 'Email'),
        ),
      );
      await tester.enterText(find.byType(TextFormField), typed);

      // Assert
      expect(controller.text, typed);
      expect(find.text(typed), findsOneWidget);
    });

    testWidgets(
      'should show the validation message when the form rejects the input',
      (tester) async {
        // Arrange
        final controller = TextEditingController();
        addTearDown(controller.dispose);
        const message = 'Email is required';
        final formKey = GlobalKey<FormState>();

        // Act
        await tester.pumpWidget(
          localizedApp(
            Form(
              key: formKey,
              child: AuthTextField(
                controller: controller,
                label: 'Email',
                validator: (value) => value == null || value.isEmpty ? message : null,
              ),
            ),
          ),
        );
        formKey.currentState!.validate();
        await tester.pump();

        // Assert
        expect(find.text(message), findsOneWidget);
      },
    );

    testWidgets(
      'should not show a validation message when the input is accepted',
      (tester) async {
        // Arrange
        final controller = TextEditingController(text: 'ada.lovelace@example.com');
        addTearDown(controller.dispose);
        final formKey = GlobalKey<FormState>();

        // Act
        await tester.pumpWidget(
          localizedApp(
            Form(
              key: formKey,
              child: AuthTextField(
                controller: controller,
                label: 'Email',
                validator: (value) => value == null || value.isEmpty ? 'Email is required' : null,
              ),
            ),
          ),
        );
        final isValid = formKey.currentState!.validate();
        await tester.pump();

        // Assert
        expect(isValid, isTrue);
        expect(find.text('Email is required'), findsNothing);
      },
    );

    testWidgets('should obscure the input when requested', (tester) async {
      // Arrange
      final controller = TextEditingController(text: 'Str0ng@Pass');
      addTearDown(controller.dispose);

      // Act
      await tester.pumpWidget(
        localizedApp(
          AuthTextField(controller: controller, label: 'Password', obscureText: true),
        ),
      );

      // Assert
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );
    });

    testWidgets('should show the text in clear when it is not obscured', (tester) async {
      // Arrange
      final controller = TextEditingController(text: 'Str0ng@Pass');
      addTearDown(controller.dispose);

      // Act
      await tester.pumpWidget(
        localizedApp(
          AuthTextField(controller: controller, label: 'Password'),
        ),
      );

      // Assert
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isFalse);
      expect(find.text('Str0ng@Pass'), findsOneWidget);
    });

    testWidgets('should render the prefix and suffix icons it receives', (tester) async {
      // Arrange
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      // Act
      await tester.pumpWidget(
        localizedApp(
          AuthTextField(
            controller: controller,
            label: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: const Icon(Icons.visibility_off_outlined),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('should forward the hint to the field decoration', (tester) async {
      // Arrange
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      const hint = 'you@example.com';

      // Act
      await tester.pumpWidget(
        localizedApp(
          AuthTextField(controller: controller, label: 'Email', hint: hint),
        ),
      );

      // Assert
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.hintText, hint);
    });

    testWidgets('should use the email keyboard type when requested', (tester) async {
      // Arrange
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      // Act
      await tester.pumpWidget(
        localizedApp(
          AuthTextField(
            controller: controller,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      );

      // Assert
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.emailAddress);
    });
  });
}