import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/shared/infrastructure/persistence/local/language_local_storage.dart';

class LocaleCubit extends Cubit<Locale> {
  final LanguageLocalStorage _storage;

  LocaleCubit(this._storage) : super(const Locale('en')) {
    _loadLocale();
  }

  void _loadLocale() {
    final code = _storage.getLanguageCode();
    if (code != null) {
      emit(Locale(code));
    }
  }

  Future<void> changeLocale(String languageCode) async {
    await _storage.saveLanguageCode(languageCode);
    emit(Locale(languageCode));
  }
}
