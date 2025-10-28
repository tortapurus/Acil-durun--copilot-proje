import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';
import '../widgets/app_bottom_navigation.dart';

class AyarlarEkrani extends StatefulWidget {
  const AyarlarEkrani({super.key});

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  bool _darkTheme = true;
  bool _showProductImages = true;
  bool _stockWarnings = true;
  bool _weeklyControlReminder = false;
  bool _emergencyAlert = true;
  bool _notificationSound = true;
  bool _vibration = true;
  bool _locationAccess = false;
  int _expiryWarningDays = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.bg1,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: ThemeColors.textWhite,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Ayarlar',
                    style: TextStyle(
                      color: ThemeColors.textWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Görünüm Section
              _buildSection('Görünüm', [
                _buildSwitchTile(
                  'Koyu Tema',
                  _darkTheme,
                  (value) => setState(() => _darkTheme = value),
                ),
                _buildSwitchTile(
                  'Ürün Resimlerini Göster',
                  _showProductImages,
                  (value) => setState(() => _showProductImages = value),
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // Yönetim Section
              _buildSection('Yönetim', [
                _buildArrowTile('Kategorileri Yönet'),
              ]),
              
              const SizedBox(height: 24),
              
              // Bildirimler Section
              _buildSection('Bildirimler', [
                _buildSwitchTile(
                  'Stok Uyarları',
                  _stockWarnings,
                  (value) => setState(() => _stockWarnings = value),
                ),
                _buildSwitchTile(
                  'Haftalık Kontrol Hatırlatıcısı',
                  _weeklyControlReminder,
                  (value) => setState(() => _weeklyControlReminder = value),
                ),
                _buildSwitchTile(
                  'Acil Durum Düdüğü',
                  _emergencyAlert,
                  (value) => setState(() => _emergencyAlert = value),
                ),
                _buildSwitchTile(
                  'Bildirim Sesi',
                  _notificationSound,
                  (value) => setState(() => _notificationSound = value),
                ),
                _buildSwitchTile(
                  'Titreşim',
                  _vibration,
                  (value) => setState(() => _vibration = value),
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // İzinler Section
              _buildSection('İzinler', [
                _buildSwitchTile(
                  'Konum Erişimi',
                  _locationAccess,
                  (value) => setState(() => _locationAccess = value),
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // Uyarı Süresi Section
              _buildSection('Uyarı Süresi', [
                _buildCounterTile(),
              ]),
              
              const SizedBox(height: 24),
              
              // Veri Yönetimi Section
              _buildSection('Veri Yönetimi', [
                _buildArrowTile('Veri Yedekle'),
                _buildArrowTile('Veri Geri Yükle'),
              ]),
              
              const SizedBox(height: 24),
              
              // GENEL Section
              _buildSection('GENEL', [
                _buildArrowTile('Uygulama Bilgileri'),
                _buildArrowTile('Yardım & Destek'),
                _buildArrowTile('Kullanım Sözleşmesi'),
                _buildArrowTile('Gizlilik Politikası'),
              ]),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(current: AppNavItem.settings),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
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
            color: ThemeColors.bgCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _addDividers(children),
          ),
        ),
      ],
    );
  }

  List<Widget> _addDividers(List<Widget> children) {
    List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(const Divider(
          color: Color(0xFF2A2A2A),
          height: 1,
          indent: 16,
          endIndent: 16,
        ));
      }
    }
    return result;
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
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
            inactiveTrackColor: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildArrowTile(String title) {
    return Padding(
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
    );
  }

  Widget _buildCounterTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'SKT\'den kaç gün önce',
              style: TextStyle(
                color: ThemeColors.textWhite,
                fontSize: 16,
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_expiryWarningDays > 1) {
                    setState(() => _expiryWarningDays--);
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ThemeColors.bgCardDark,
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
                _expiryWarningDays.toString(),
                style: const TextStyle(
                  color: ThemeColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  if (_expiryWarningDays < 365) {
                    setState(() => _expiryWarningDays++);
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ThemeColors.bgCardDark,
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
}