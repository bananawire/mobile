import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/iam/infrastructure/oauth/google/google_sign_in_id_token_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

void main() {
  late MockGoogleSignIn googleSignIn;
  late GoogleSignInIdTokenProvider provider;

  setUp(() {
    googleSignIn = MockGoogleSignIn();
    provider = GoogleSignInIdTokenProvider(googleSignIn);
  });

  group('GoogleSignInIdTokenProvider.fetchIdToken', () {
    test('should return the id token exposed by the signed in account', () async {
      // Arrange
      final authentication = MockGoogleSignInAuthentication();
      when(() => authentication.idToken).thenReturn('google-id-token');
      final account = MockGoogleSignInAccount();
      when(() => account.authentication).thenAnswer((_) async => authentication);
      when(() => googleSignIn.signIn()).thenAnswer((_) async => account);

      // Act
      final idToken = await provider.fetchIdToken();

      // Assert
      expect(idToken, 'google-id-token');
      verify(() => googleSignIn.signIn()).called(1);
    });

    test('should throw when the user cancels the sign in flow', () async {
      // Arrange
      when(() => googleSignIn.signIn()).thenAnswer((_) async => null);

      // Act
      final call = provider.fetchIdToken();

      // Assert
      await expectLater(
        call,
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Google sign-in was cancelled'),
          ),
        ),
      );
    });

    test('should throw when the account exposes no id token', () async {
      // Arrange
      final authentication = MockGoogleSignInAuthentication();
      when(() => authentication.idToken).thenReturn(null);
      final account = MockGoogleSignInAccount();
      when(() => account.authentication).thenAnswer((_) async => authentication);
      when(() => googleSignIn.signIn()).thenAnswer((_) async => account);

      // Act
      final call = provider.fetchIdToken();

      // Assert
      await expectLater(
        call,
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('serverClientId'),
          ),
        ),
      );
    });

    test('should throw when the account exposes a blank id token', () async {
      // Arrange
      final authentication = MockGoogleSignInAuthentication();
      when(() => authentication.idToken).thenReturn('   ');
      final account = MockGoogleSignInAccount();
      when(() => account.authentication).thenAnswer((_) async => authentication);
      when(() => googleSignIn.signIn()).thenAnswer((_) async => account);

      // Act
      final call = provider.fetchIdToken();

      // Assert
      await expectLater(
        call,
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('serverClientId'),
          ),
        ),
      );
    });
  });
}