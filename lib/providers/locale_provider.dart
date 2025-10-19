import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleProvider with ChangeNotifier {
  late Box _settingsBox;
  Locale _locale = const Locale('tr');

  Locale get locale => _locale;

  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
    final String? savedLocale = _settingsBox.get('locale');
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _settingsBox.put('locale', locale.languageCode);
    notifyListeners();
  }
}
