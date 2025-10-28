import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';

class AppThemeColors {
  AppThemeColors._(this._settings);

  final SettingsService _settings;

  static AppThemeColors watch(BuildContext context) {
    return AppThemeColors._(context.watch<SettingsService>());
  }

  static AppThemeColors read(BuildContext context) {
    return AppThemeColors._(context.read<SettingsService>());
  }

  Color get bg1 => _settings.palette.bg1;
  Color get bg2 => _settings.palette.bg2;
  Color get bg3 => _settings.palette.bg3;
  Color get bgCard => _settings.palette.bgCard;
  Color get bgCardDark => _settings.palette.bgCardDark;

  Color get navigationBorder => _settings.isDarkTheme
      ? const Color(0xFF2C2C2C)
      : const Color(0xFF2F3633);

  Color get divider => _settings.isDarkTheme
      ? const Color(0xFF2A2A2A)
      : const Color(0xFF313938);

  Color tinted(Color base, {double amount = 0.12}) {
    return Color.lerp(base, Colors.white, amount.clamp(0, 1)) ?? base;
  }
}
