import 'package:shared_preferences/shared_preferences.dart';

class RegistrationSessionLocalStorage {
  static const _registrationSessionIdKey = 'registration_session_id';

  Future<void> saveSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registrationSessionIdKey, sessionId);
  }

  Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_registrationSessionIdKey);
  }

  Future<void> clearSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_registrationSessionIdKey);
  }
}
