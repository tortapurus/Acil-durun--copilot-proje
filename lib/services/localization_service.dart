import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();
  LocalizationService._();

  Map<String, String> _localizedValues = {};
  Map<String, String> _fallbackValues = {};
  String _currentLanguage = 'tr';

  // Desteklenen diller
  static const Map<String, String> supportedLanguages = {
    'tr': 'Türkçe',
    'en': 'English',
    'ar': 'العربية',
    'de': 'Deutsch',
    'es': 'Español',
    'fr': 'Français',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'hi': 'हिन्दी',
    'bn': 'বাংলা',
    'ur': 'اردو',
    'fa': 'فارسی',
    'am': 'አማርኛ',
    'so': 'Soomaali',
    'my': 'မြန်မာ',
    'uk': 'Українська',
  };

  String get currentLanguage => _currentLanguage;
  Map<String, String> get availableLanguages => supportedLanguages;

  // Dil yükleme
  Future<void> loadLanguage(String languageCode) async {
    try {
      _currentLanguage = languageCode;

      if (_fallbackValues.isEmpty) {
        final fallbackJson = await rootBundle.loadString('assets/lang/tr.json');
        final fallbackMap = json.decode(fallbackJson) as Map<String, dynamic>;
        _fallbackValues = fallbackMap.map((key, value) => MapEntry(key, value.toString()));
      }
      
      // JSON dosyasını yükle
      String jsonString = await rootBundle.loadString('assets/lang/$languageCode.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      _localizedValues = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      
      // Seçilen dili kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', languageCode);
      
    } catch (e) {
      // Varsayılan olarak Türkçe yükle
      if (languageCode != 'tr') {
        await loadLanguage('tr');
      } else {
        _localizedValues = _fallbackValues;
      }
    }
  }

  // Kaydedilmiş dili yükle
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String savedLanguage = prefs.getString('selected_language') ?? 'tr';
    await loadLanguage(savedLanguage);
  }

  // Çeviri al
  String translate(String key, [Map<String, String>? replacements]) {
  String translation = _localizedValues[key] ?? _fallbackValues[key] ?? key;
    
    // Placeholder değiştirme
    if (replacements != null) {
      replacements.forEach((placeholder, value) {
        translation = translation.replaceAll('{$placeholder}', value);
      });
    }
    
    return translation;
  }

  // Dil değiştir
  Future<void> changeLanguage(String languageCode) async {
    if (supportedLanguages.containsKey(languageCode)) {
      await loadLanguage(languageCode);
      notifyListeners(); // Widget'ları güncelle
    }
  }

  // Kısa kod
  String t(String key, [Map<String, String>? replacements]) {
    return translate(key, replacements);
  }
}