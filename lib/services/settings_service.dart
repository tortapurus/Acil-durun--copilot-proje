import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_colors.dart';
import 'localization_service.dart';
import 'notification_service.dart';
import 'data_service.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._internal();

  static final SettingsService instance = SettingsService._internal();

  static const String _prefDarkTheme = 'settings.dark_theme';
  static const String _prefShowProductImages = 'settings.show_product_images';
  static const String _prefStockAlerts = 'settings.stock_alerts';
  static const String _prefWeeklyReminder = 'settings.weekly_reminder';
  static const String _prefEmergencyAlert = 'settings.emergency_alert';
  static const String _prefNotificationSound = 'settings.notification_sound';
  static const String _prefVibration = 'settings.vibration';
  static const String _prefExpiryWarningDays = 'settings.expiry_warning_days';

  bool _isDarkTheme = true;
  bool _showProductImages = true;
  bool _stockAlerts = true;
  bool _weeklyReminder = false;
  bool _emergencyAlert = true;
  bool _notificationSound = true;
  bool _vibration = true;
  int _expiryWarningDays = 30;
  bool _initialized = false;

  final NotificationService _notificationService = NotificationService();

  bool get isDarkTheme => _isDarkTheme;
  bool get showProductImages => _showProductImages;
  bool get stockAlertsEnabled => _stockAlerts;
  bool get weeklyReminderEnabled => _weeklyReminder;
  bool get emergencyAlertEnabled => _emergencyAlert;
  bool get notificationSoundEnabled => _notificationSound;
  bool get vibrationEnabled => _vibration;
  int get expiryWarningDays => _expiryWarningDays;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool(_prefDarkTheme) ?? true;
    _showProductImages = prefs.getBool(_prefShowProductImages) ?? true;
    _stockAlerts = prefs.getBool(_prefStockAlerts) ?? true;
    _weeklyReminder = prefs.getBool(_prefWeeklyReminder) ?? false;
    _emergencyAlert = prefs.getBool(_prefEmergencyAlert) ?? true;
    _notificationSound = prefs.getBool(_prefNotificationSound) ?? true;
    _vibration = prefs.getBool(_prefVibration) ?? true;
    _expiryWarningDays = prefs.getInt(_prefExpiryWarningDays) ?? 30;
    _initialized = true;

    DataService.instance.addListener(_handleDataUpdates);

    if (_weeklyReminder) {
      await _scheduleWeeklyReminder();
    }
    if (_stockAlerts) {
      await _refreshStockNotifications();
    }
  }

  Future<void> setDarkTheme(bool value) async {
    if (_isDarkTheme == value) {
      return;
    }

    _isDarkTheme = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefDarkTheme, value);
    notifyListeners();
  }

  Future<void> setShowProductImages(bool value) async {
    if (_showProductImages == value) {
      return;
    }

    _showProductImages = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefShowProductImages, value);
    notifyListeners();
  }

  Future<void> setStockAlerts(bool value) async {
    if (_stockAlerts == value) {
      return;
    }
    _stockAlerts = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefStockAlerts, value);
    if (value) {
      await _refreshStockNotifications();
    } else {
      await _notificationService.cancelNotification(_NotificationIds.stockAlert);
    }
    notifyListeners();
  }

  Future<void> setWeeklyReminder(bool value) async {
    if (_weeklyReminder == value) {
      return;
    }
    _weeklyReminder = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefWeeklyReminder, value);

    if (value) {
      await _scheduleWeeklyReminder();
    } else {
      await _notificationService.cancelNotification(_NotificationIds.weeklyReminder);
    }

    notifyListeners();
  }

  Future<void> setEmergencyAlert(bool value) async {
    if (_emergencyAlert == value) {
      return;
    }
    _emergencyAlert = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEmergencyAlert, value);
    notifyListeners();
  }

  Future<void> setNotificationSound(bool value) async {
    if (_notificationSound == value) {
      return;
    }
    _notificationSound = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefNotificationSound, value);
    if (_weeklyReminder) {
      await _scheduleWeeklyReminder();
    }
    notifyListeners();
  }

  Future<void> setVibration(bool value) async {
    if (_vibration == value) {
      return;
    }
    _vibration = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefVibration, value);
    if (_weeklyReminder) {
      await _scheduleWeeklyReminder();
    }
    notifyListeners();
  }

  Future<void> setExpiryWarningDays(int value) async {
    if (value == _expiryWarningDays) {
      return;
    }
    _expiryWarningDays = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefExpiryWarningDays, value);
    notifyListeners();
  }

  ThemeData get themeData {
    final ThemePalette palette = _isDarkTheme ? ThemePalette.dark() : ThemePalette.dim();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.bg1,
      canvasColor: palette.bg1,
      cardColor: palette.bgCard,
      dialogTheme: DialogThemeData(
        backgroundColor: palette.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeColors.primaryGreen,
        brightness: Brightness.dark,
        surface: palette.bgCard,
        primary: ThemeColors.primaryGreen,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        fillColor: palette.bgCardDark,
        filled: true,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: ThemeColors.textWhite,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.bg3,
        contentTextStyle: const TextStyle(color: ThemeColors.textWhite),
      ),
    );
  }

  ThemePalette get palette => _isDarkTheme ? ThemePalette.dark() : ThemePalette.dim();

  Future<void> _scheduleWeeklyReminder() async {
    await _notificationService.cancelNotification(_NotificationIds.weeklyReminder);
    final now = DateTime.now();
    DateTime scheduled = DateTime(now.year, now.month, now.day, 9, 0);
    while (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final loc = LocalizationService.instance;
    final title = loc.t('notifications.weeklyReminder.title');
    final body = loc.t('notifications.weeklyReminder.body');

    await _notificationService.scheduleReminder(
      id: _NotificationIds.weeklyReminder,
      title: title,
      body: body,
      scheduledTime: scheduled,
      playSound: _notificationSound,
      enableVibration: _vibration,
    );
  }

  Future<void> _refreshStockNotifications() async {
    if (!_stockAlerts) {
      return;
    }

    final data = DataService.instance;
    final expired = data.expiredProductCount;
    final missing = data.outOfStockProductCount;

    if (expired == 0 && missing == 0) {
      await _notificationService.cancelNotification(_NotificationIds.stockAlert);
      return;
    }

    final loc = LocalizationService.instance;
    final title = loc.t('notifications.stockAlert.title');

    final List<String> parts = [];
    if (expired > 0) {
      parts.add(
        loc.t('notifications.stockAlert.expired', {
          'count': expired.toString(),
        }),
      );
    }
    if (missing > 0) {
      parts.add(
        loc.t('notifications.stockAlert.missing', {
          'count': missing.toString(),
        }),
      );
    }
    final body = parts.join(' ');

    await _notificationService.showNotification(
      id: _NotificationIds.stockAlert,
      title: title,
      body: body,
      playSound: _notificationSound,
      enableVibration: _vibration,
    );
  }

  void _handleDataUpdates() {
    if (!_stockAlerts) {
      return;
    }
    unawaited(_refreshStockNotifications());
  }
}

class ThemePalette {
  const ThemePalette._({
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.bgCard,
    required this.bgCardDark,
  });

  factory ThemePalette.dark() {
    return const ThemePalette._(
      bg1: ThemeColors.bg1,
      bg2: ThemeColors.bg2,
      bg3: ThemeColors.bg3,
      bgCard: ThemeColors.bgCard,
      bgCardDark: ThemeColors.bgCardDark,
    );
  }

  factory ThemePalette.dim() {
    return const ThemePalette._(
      bg1: Color(0xFF151B18),
      bg2: Color(0xFF131A16),
      bg3: Color(0xFF1C191F),
      bgCard: Color(0xFF202725),
      bgCardDark: Color(0xFF1A1F1D),
    );
  }

  final Color bg1;
  final Color bg2;
  final Color bg3;
  final Color bgCard;
  final Color bgCardDark;
}

class _NotificationIds {
  static const int weeklyReminder = 2001;
  static const int stockAlert = 2002;
}
