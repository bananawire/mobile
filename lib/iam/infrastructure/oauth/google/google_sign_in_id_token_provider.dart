import 'package:google_sign_in/google_sign_in.dart';

import 'google_id_token_provider.dart';

class GoogleSignInIdTokenProvider implements GoogleIdTokenProvider {
  final GoogleSignIn _googleSignIn;

  GoogleSignInIdTokenProvider(this._googleSignIn);

  @override
  Future<String> fetchIdToken() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google sign-in was cancelled');
    }

    final authentication = await account.authentication;
    final idToken = authentication.idToken;

    if (idToken == null || idToken.trim().isEmpty) {
      throw Exception(
        'Google ID token is not available. Ensure GoogleSignIn is configured with serverClientId.',
      );
    }

    return idToken;
  }
}
