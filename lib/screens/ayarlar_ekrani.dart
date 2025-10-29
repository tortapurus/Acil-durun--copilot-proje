import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../services/settings_service.dart';
import '../models/product.dart';
import '../models/bag.dart';
import '../models/depot.dart';
import '../theme/theme_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';

class AyarlarEkrani extends StatefulWidget {
  const AyarlarEkrani({super.key});

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  bool _locationAccess = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocalizationService, SettingsService>(
      builder: (context, loc, settings, child) {
  final colors = AppThemeColors.read(context);
  return Scaffold(
  backgroundColor: colors.bg1,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.t('settings'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ThemeColors.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Görünüm Section
                _buildSection(loc.t('settings.appearance'), [
                  _buildSwitchTile(
                    loc.t('settings.dark_theme'),
                    settings.isDarkTheme,
                    (value) {
                      settings.setDarkTheme(value);
                    },
                    colors,
                  ),
                  _buildArrowTile(
                    loc.t('settings.language'),
                    onTap: () async {
                      final result = await Navigator.pushNamed(context, '/language-selection');
                      if (result == true) {
                        setState(() {}); // Refresh UI after language change
                      }
                    },
                  ),
                  _buildSwitchTile(
                    loc.t('settings.show_product_images'),
                    settings.showProductImages,
                    (value) {
                      settings.setShowProductImages(value);
                    },
                    colors,
                  ),
                ], colors),
                
                const SizedBox(height: 24),
                
                // Yönetim Section
                _buildSection(loc.t('settings.management'), [
                  _buildArrowTile(
                    loc.t('settings.manage_categories'),
                    onTap: () => Navigator.pushNamed(context, '/yonetim-paneli'),
                  ),
                  _buildArrowTile(
                    loc.t('settings.load_sample_data'),
                    onTap: () async {
                      await _loadSampleData();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.t('settings.sample_data_loaded'))),
                      );
                    },
                  ),
                  _buildArrowTile(
                    loc.t('settings.clear_sample_data'),
                    onTap: () async {
                      await _clearSampleData();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.t('settings.sample_data_cleared'))),
                      );
                    },
                  ),
                ], colors),
                
                const SizedBox(height: 24),
                
                // Bildirimler Section
                _buildSection(loc.t('settings.notifications'), [
                  _buildSwitchTile(
                    loc.t('settings.stock_warnings'),
                    settings.stockAlertsEnabled,
                    (value) => settings.setStockAlerts(value),
                    colors,
                  ),
                  _buildSwitchTile(
                    loc.t('settings.weekly_reminder'),
                    settings.weeklyReminderEnabled,
                    (value) => settings.setWeeklyReminder(value),
                    colors,
                  ),
                  _buildSwitchTile(
                    loc.t('settings.emergency_alert'),
                    settings.emergencyAlertEnabled,
                    (value) => settings.setEmergencyAlert(value),
                    colors,
                  ),
                  _buildSwitchTile(
                    loc.t('settings.notification_sound'),
                    settings.notificationSoundEnabled,
                    (value) => settings.setNotificationSound(value),
                    colors,
                  ),
                  _buildSwitchTile(
                    loc.t('settings.vibration'),
                    settings.vibrationEnabled,
                    (value) => settings.setVibration(value),
                    colors,
                  ),
                ], colors),
                
                const SizedBox(height: 24),
                
                // İzinler Section
                _buildSection(loc.t('settings.permissions'), [
                  _buildSwitchTile(
                    loc.t('settings.location_access'),
                    _locationAccess,
                    (value) => setState(() => _locationAccess = value),
                    colors,
                  ),
                ], colors),
                
                const SizedBox(height: 24),
                
                // Uyarı Süresi Section
                _buildSection(loc.t('settings.warning_time'), [
                  _buildCounterTile(
                    loc,
                    colors,
                    settings.expiryWarningDays,
                    onChanged: (value) => settings.setExpiryWarningDays(value),
                  ),
                ], colors),
                
                const SizedBox(height: 24),
                
                // Veri Yönetimi Section
                _buildSection(loc.t('settings.data_management'), [
                  _buildArrowTile(
                    loc.t('settings.backup_data'),
                    onTap: () => _handleBackup(loc),
                  ),
                  _buildArrowTile(
                    loc.t('settings.restore_data'),
                    onTap: () => _handleRestore(loc),
                  ),
                ], colors),
                
                const SizedBox(height: 24),
                
                // GENEL Section
                _buildSection(loc.t('settings.general'), [
                  _buildArrowTile(
                    loc.t('emergency.numbers'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/acil-numaralar',
                    ),
                  ),
                  _buildArrowTile(
                    loc.t('settings.app_info'),
                    onTap: () => Navigator.pushNamed(context, '/app-info'),
                  ),
                  _buildArrowTile(loc.t('settings.help_support')),
                  _buildArrowTile(loc.t('settings.terms')),
                  _buildArrowTile(loc.t('settings.privacy')),
                ], colors),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(current: AppNavItem.settings),
      );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children, AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ThemeColors.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.bgCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _addDividers(children, colors.divider),
          ),
        ),
      ],
    );
  }

  List<Widget> _addDividers(List<Widget> children, Color dividerColor) {
    List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Divider(
          color: dividerColor,
          height: 1,
          indent: 16,
          endIndent: 16,
        ));
      }
    }
    return result;
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged, AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: ThemeColors.textWhite,
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: ThemeColors.pastelGreen,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: colors.tinted(ThemeColors.textGrey, amount: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowTile(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: ThemeColors.textWhite,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: ThemeColors.textGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterTile(
    LocalizationService loc,
    AppThemeColors colors,
    int value, {
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              loc.t('settings.days_before_expiry'),
              style: const TextStyle(
                color: ThemeColors.textWhite,
                fontSize: 16,
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (value > 1) {
                    onChanged(value - 1);
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.bgCardDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: ThemeColors.textWhite,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                value.toString(),
                style: const TextStyle(
                  color: ThemeColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  if (value < 365) {
                    onChanged(value + 1);
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.bgCardDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: ThemeColors.textWhite,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleBackup(LocalizationService loc) async {
    final dataService = DataService.instance;

    try {
      final snapshot = dataService.exportSnapshot();
      final String defaultFileName =
          'acil_durum_yedek_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

      String? savePath;

      // Try to let the user pick a directory on platforms that support it (Android).
      try {
        final String? directoryPath = await FilePicker.platform.getDirectoryPath(
          dialogTitle: loc.t('settings.backup_save_title'),
        );
        if (directoryPath != null && directoryPath.isNotEmpty) {
          savePath = '$directoryPath${Platform.pathSeparator}$defaultFileName';
        }
      } catch (e) {
        // Some platforms (e.g. iOS) or older plugin versions may not implement getDirectoryPath.
        savePath = null;
      }

      // If directory picker wasn't available or user cancelled, fall back to a save-file dialog
      // (desktop) or the app documents directory (mobile).
      if (savePath == null) {
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          final String? picked = await FilePicker.platform.saveFile(
            dialogTitle: loc.t('settings.backup_save_title'),
            fileName: defaultFileName,
            type: FileType.custom,
            allowedExtensions: const ['json'],
          );
          savePath = picked;
        } else {
          // Mobile fallback: write to app documents directory
          final directory = await getApplicationDocumentsDirectory();
          savePath = '${directory.path}${Platform.pathSeparator}$defaultFileName';
        }
      }

      if (savePath == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.t('settings.backup_cancelled'))),
        );
        return;
      }

      final file = File(savePath);
      final encoded = jsonEncode(snapshot);

      // Try writing; if it fails (e.g. platform path is a content URI or permission denied),
      // fall back to a save-file dialog (desktop) or the app documents directory.
      try {
        await file.writeAsString(encoded, flush: true);
      } catch (e) {
        // Attempt alternative save methods
        bool saved = false;
        try {
          // Desktop: try saveFile dialog
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
            final String? picked = await FilePicker.platform.saveFile(
              dialogTitle: loc.t('settings.backup_save_title'),
              fileName: defaultFileName,
              type: FileType.custom,
              allowedExtensions: const ['json'],
            );
            if (picked != null) {
              final f = File(picked);
              await f.writeAsString(encoded, flush: true);
              savePath = picked;
              saved = true;
            }
          } else {
            // Mobile: fallback to app documents directory
            final directory = await getApplicationDocumentsDirectory();
            final fallback = '${directory.path}${Platform.pathSeparator}$defaultFileName';
            final f = File(fallback);
            await f.writeAsString(encoded, flush: true);
            savePath = fallback;
            saved = true;
          }
        } catch (e2) {
          // both attempts failed
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${loc.t('settings.backup_error')} (${e.toString()}; ${e2.toString()})'),
            ),
          );
          return;
        }

        if (!saved) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.t('settings.backup_cancelled'))),
          );
          return;
        }
      }

      if (!mounted) {
        return;
      }

  final segments = savePath.split(RegExp(r'[\\/]'));
  final fileName = segments.isNotEmpty ? segments.last : defaultFileName;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.t('settings.backup_success', {
              'path': fileName,
            }),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('settings.backup_error')),
        ),
      );
    }
  }

  Future<void> _handleRestore(LocalizationService loc) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );

      if (result == null || result.files.isEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.t('settings.restore_cancelled')),
          ),
        );
        return;
      }

    final PlatformFile fileInfo = result.files.first;

      final String? path = fileInfo.path;
      final String content;

      if (path != null) {
        final file = File(path);
        if (!await file.exists()) {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.t('settings.restore_invalid')),
            ),
          );
          return;
        }
        content = await file.readAsString();
      } else if (fileInfo.bytes != null) {
        content = utf8.decode(fileInfo.bytes!);
      } else {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.t('settings.restore_invalid')),
          ),
        );
        return;
      }

      final dynamic decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.t('settings.restore_invalid')),
          ),
        );
        return;
      }

      await DataService.instance.importSnapshot(Map<String, dynamic>.from(decoded));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('settings.restore_success')),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('settings.restore_error')),
        ),
      );
    }
  }

  Future<void> _loadSampleData() async {
    final dataService = DataService.instance;

    // create sample depot
    final depotId = 'depot_${DateTime.now().microsecondsSinceEpoch}';
    final depot = Depot(id: depotId, name: 'Örnek Depo 1', notes: 'Otomatik oluşturulmuş örnek depo');
    dataService.addDepot(depot);

    // create sample bags
    final bag1Id = 'bag_${DateTime.now().microsecondsSinceEpoch}_a';
    final bag2Id = 'bag_${DateTime.now().microsecondsSinceEpoch}_b';
    final bag1 = Bag(id: bag1Id, name: 'Örnek Çanta 1', notes: 'İçinde temel malzemeler bulunur');
    final bag2 = Bag(id: bag2Id, name: 'Örnek Çanta 2', notes: 'İkinci örnek çanta');
    dataService.addBag(bag1);
    dataService.addBag(bag2);

    // create some sample products and attach to bag/depot
    final now = DateTime.now();
    final p1 = Product(
      id: 'prod_${now.microsecondsSinceEpoch}_1',
      name: 'Şişelenmiş Su',
      categoryId: 'water',
      expiryDate: now.add(const Duration(days: 365)),
      reminderDate: now.add(const Duration(days: 330)),
      storageId: bag1Id,
      storageType: StorageLocationType.bag,
      createdAt: now,
    );

    final p2 = Product(
      id: 'prod_${now.microsecondsSinceEpoch}_2',
      name: 'Konserve Ton Balığı',
      categoryId: 'canned_food',
      expiryDate: now.add(const Duration(days: 720)),
      reminderDate: now.add(const Duration(days: 700)),
      storageId: depotId,
      storageType: StorageLocationType.depot,
      createdAt: now,
    );

    final p3 = Product(
      id: 'prod_${now.microsecondsSinceEpoch}_3',
      name: 'İlk Yardım Seti (Örnek)',
      categoryId: 'first_aid_kit',
      expiryDate: now.add(const Duration(days: 400)),
      reminderDate: now.add(const Duration(days: 360)),
      storageId: bag2Id,
      storageType: StorageLocationType.bag,
      createdAt: now,
    );

    dataService.addProduct(p1);
    dataService.addProduct(p2);
    dataService.addProduct(p3);
  }

  Future<void> _clearSampleData() async {
    final snapshot = {
      'version': 1,
      'generatedAt': DateTime.now().toIso8601String(),
      'products': <dynamic>[],
      'bags': <dynamic>[],
      'depots': <dynamic>[],
      'customCategories': <dynamic>[],
    };

    await DataService.instance.importSnapshot(snapshot);
  }
}