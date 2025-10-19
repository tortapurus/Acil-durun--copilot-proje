import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales => [
        const Locale('tr'),
        const Locale('en'),
        const Locale('hi'),
        const Locale('es'),
        const Locale('ar'),
        const Locale('pt'),
        const Locale('it'),
        const Locale('fr'),
        const Locale('de'),
        const Locale('ja'),
        const Locale('ko'),
        const Locale('fa'),
        const Locale('uk'),
        const Locale('bn'),
        const Locale('ur'),
        const Locale('my'),
        const Locale('am'),
        const Locale('so'),
        const Locale('zh'),
        const Locale('ru'),
      ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String? translate(String key) {
    return _localizedStrings[key];
  }

  // Anahtarlar
  String get app_name => translate('app.name')!;
  String get home_title => translate('home.title')!;
  String get add_item => translate('add.item')!;
  String get category => translate('category')!;
  String get expiry_date => translate('expiry.date')!;
  String get reminder_date => translate('reminder.date')!;
  String get notes => translate('notes')!;
  String get location_note => translate('location.note')!;
  String get save => translate('save')!;
  String get edit => translate('edit')!;
  String get delete => translate('delete')!;
  String get search => translate('search')!;
  String get settings => translate('settings')!;
  String get notification_days_before => translate('notification.days.before')!;
  String get emergency_numbers => translate('emergency.numbers')!;
  String get police_fire => translate('police.fire')!;
  String get afad => translate('afad')!;
  String get forest_fire => translate('forest.fire')!;
  String get safe => translate('safe')!;
  String get expiring_soon => translate('expiring.soon')!;
  String get expired => translate('expired')!;
  String get alerts => translate('alerts')!;
  String get water => translate('water')!;
  String get food => translate('food')!;
  String get medical => translate('medical')!;
  String get blanket => translate('blanket')!;
  String get total_items => translate('total.items')!;
  String get emergency_kits => translate('emergency.kits')!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((element) => element.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}