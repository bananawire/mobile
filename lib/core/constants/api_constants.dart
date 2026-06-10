import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['CLAIR_BACKEND_BASE_URL']!;

  // Public OAuth client id used to request a Google idToken on Android.
  // This is not a secret (unlike client_secret).
  static String get googleServerClientId => dotenv.env['GOOGLE_OAUTH_WEB_CLIENT_ID']!;

  static const String apiPrefix = '/api/v1';
  static const String authBase = '$apiPrefix/auth';
}
