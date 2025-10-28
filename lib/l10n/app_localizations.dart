import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? localization =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(localization != null,
        'AppLocalizations.of() called with a context that does not contain AppLocalizations.');
    return localization!;
  }

  Future<bool> load() async {
    final Map<String, dynamic> defaultStrings =
        await _loadJsonFile(const Locale('tr'));

    Map<String, dynamic> localeStrings = {};
    if (locale.languageCode != 'tr') {
      localeStrings = await _loadJsonFile(locale, fallbackToEmpty: true);
    } else {
      localeStrings = defaultStrings;
    }

    _localizedStrings = {
      ...defaultStrings,
      ...localeStrings,
    };
    return true;
  }

  Future<Map<String, dynamic>> _loadJsonFile(Locale locale,
      {bool fallbackToEmpty = false}) async {
    final String code = locale.languageCode.toLowerCase();
    try {
      final String jsonString =
          await rootBundle.loadString('assets/lang/$code.json');
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      if (fallbackToEmpty) {
        return {};
      }
      rethrow;
    }
  }

  String translate(String key, {Map<String, String>? replacements}) {
    String value = _localizedStrings[key]?.toString() ?? key;
    if (replacements != null) {
      replacements.forEach((placeholder, replacement) {
        value = value.replaceAll('{$placeholder}', replacement);
      });
    }
    return value;
  }

  static const List<Locale> supportedLocales = [
    Locale('tr'),
    Locale('en'),
    Locale('ar'),
    Locale('de'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('uk'),
    Locale('bn'),
    Locale('ur'),
    Locale('my'),
    Locale('am'),
    Locale('so'),
    Locale('zh'),
  ];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
