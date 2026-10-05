import 'package:shared_preferences/shared_preferences.dart';

class LanguageLocalStorage {
  static const _languageCodeKey = 'selected_language_code';
  final SharedPreferences _prefs;

  LanguageLocalStorage(this._prefs);

  Future<void> saveLanguageCode(String languageCode) async {
    await _prefs.setString(_languageCodeKey, languageCode);
  }

  String? getLanguageCode() {
    return _prefs.getString(_languageCodeKey);
  }

  Future<void> clearLanguage() async {
    await _prefs.remove(_languageCodeKey);
  }
}
