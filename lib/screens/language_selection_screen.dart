import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../theme/theme_colors.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final LocalizationService _localizationService = LocalizationService.instance;
  late String _selectedLanguage;

  // Bayrak emoji'leri
  static const Map<String, String> _languageFlags = {
    'tr': '🇹🇷',
    'en': '🇬🇧',
    'ar': '🇸🇦',
    'de': '🇩🇪',
    'es': '🇪🇸',
    'fr': '🇫🇷',
    'it': '🇮🇹',
    'pt': '🇧🇷',
    'ru': '🇷🇺',
    'zh': '🇨🇳',
    'ja': '🇯🇵',
    'ko': '🇰🇷',
    'hi': '🇮🇳',
    'bn': '🇧🇩',
    'ur': '🇵🇰',
    'fa': '🇮🇷',
    'am': '🇪🇹',
    'so': '🇸🇴',
    'my': '🇲🇲',
    'uk': '🇺🇦',
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _localizationService.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.bg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ThemeColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _localizationService.t('settings.language'),
          style: const TextStyle(
            color: ThemeColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: LocalizationService.supportedLanguages.length,
                itemBuilder: (context, index) {
                  final entry = LocalizationService.supportedLanguages.entries.elementAt(index);
                  final languageCode = entry.key;
                  final languageName = entry.value;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: ThemeColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: _selectedLanguage == languageCode
                          ? Border.all(
                              color: ThemeColors.pastelGreen,
                              width: 2,
                            )
                          : null,
                    ),
                    child: ListTile(
                      leading: Text(
                        _languageFlags[languageCode] ?? '🌐',
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(
                        languageName,
                        style: const TextStyle(
                          color: ThemeColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: _selectedLanguage == languageCode
                          ? const Icon(
                              Icons.check,
                              color: ThemeColors.pastelGreen,
                              size: 24,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedLanguage = languageCode;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await _localizationService.changeLanguage(_selectedLanguage);
                  if (!context.mounted) return;
                  Navigator.pop(context, true); // true = language changed
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.pastelGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _localizationService.t('save'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}