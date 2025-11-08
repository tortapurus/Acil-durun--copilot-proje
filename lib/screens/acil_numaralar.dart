import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/localization_service.dart';
import '../services/phone_call_service.dart';
import '../services/data_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/app_bottom_navigation.dart';

class AcilNumaralar extends StatefulWidget {
  const AcilNumaralar({super.key});

  @override
  State<AcilNumaralar> createState() => _AcilNumaralarState();
}

class _AcilNumaralarState extends State<AcilNumaralar> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showAddContactDialog(BuildContext context, LocalizationService loc) {
    _nameController.clear();
    _phoneController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColors.bgCard,
          title: Text(
            loc.t('emergency.add.title'),
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Kişi Adı TextField
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: ThemeColors.textWhite),
                  decoration: InputDecoration(
                    labelText: loc.t('emergency.add.name'),
                    labelStyle: const TextStyle(color: ThemeColors.textGrey),
                    hintText: loc.t('emergency.add.name_placeholder'),
                    hintStyle: const TextStyle(color: ThemeColors.textGrey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: ThemeColors.textGrey,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: ThemeColors.pastelGreen,
                        width: 1,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: ThemeColors.textGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Telefon Numarası TextField
                TextField(
                  controller: _phoneController,
                  style: const TextStyle(color: ThemeColors.textWhite),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: loc.t('emergency.add.phone'),
                    labelStyle: const TextStyle(color: ThemeColors.textGrey),
                    hintText: loc.t('emergency.add.phone_placeholder'),
                    hintStyle: const TextStyle(color: ThemeColors.textGrey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: ThemeColors.textGrey,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: ThemeColors.pastelGreen,
                        width: 1,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: ThemeColors.textGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                loc.t('emergency.add.cancel'),
                style: const TextStyle(
                  color: ThemeColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final phone = _phoneController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.t('emergency.add.error.name')),
                      backgroundColor: ThemeColors.pastelRed,
                    ),
                  );
                  return;
                }

                if (phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.t('emergency.add.error.phone')),
                      backgroundColor: ThemeColors.pastelRed,
                    ),
                  );
                  return;
                }

                await DataService.instance.addEmergencyContact(name, phone);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text(
                loc.t('emergency.add.button'),
                style: const TextStyle(
                  color: ThemeColors.pastelGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _makeCall(BuildContext context, LocalizationService loc, String number) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColors.bgCard,
          title: Text(
            loc.t('emergency.numbers.confirm.title'),
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            loc.t('emergency.numbers.confirm.message', {'number': number}),
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                loc.t('emergency.numbers.confirm.cancel'),
                style: const TextStyle(
                  color: ThemeColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                loc.t('emergency.numbers.confirm.call'),
                style: const TextStyle(
                  color: ThemeColors.pastelRed,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await PhoneCallService.makeDirectCall(number);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, loc, child) => Scaffold(
        backgroundColor: ThemeColors.bg1,
        appBar: AppBar(
          backgroundColor: ThemeColors.bg1,
          elevation: 0,
          title: Text(
            loc.t('emergency.title'),
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Image.asset(
                  'assets/icons/acil durum telefonu ekle.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
                onPressed: () => _showAddContactDialog(context, loc),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<DataService>(
            builder: (context, dataService, _) {
              final customContacts = dataService.customEmergencyContacts;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Eklenen Numaralar Bölümü
                  if (customContacts.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        loc.t('emergency.contacts.custom'),
                        style: const TextStyle(
                          color: ThemeColors.textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...customContacts.asMap().entries.map((entry) {
                      final contact = entry.value;
                      final color = dataService.getAvatarColor(contact.avatarColorIndex);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ThemeColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _makeCall(context, loc, contact.phone),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      backgroundColor: color,
                                      radius: 28,
                                      child: Text(
                                        contact.avatarInitial,
                                        style: const TextStyle(
                                          color: ThemeColors.textBlack,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Bilgiler
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contact.name,
                                            style: const TextStyle(
                                              color: ThemeColors.textWhite,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            contact.phone,
                                            style: const TextStyle(
                                              color: ThemeColors.textGrey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Sil Butonu
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: ThemeColors.pastelRed,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: ThemeColors.bgCard,
                                              title: Text(
                                                loc.t('emergency.delete.title'),
                                                style: const TextStyle(
                                                  color: ThemeColors.textWhite,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: Text(
                                                loc.t('emergency.delete.confirm'),
                                                style: const TextStyle(
                                                  color: ThemeColors.textWhite,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: Text(
                                                    loc.t('common.cancel'),
                                                    style: const TextStyle(
                                                      color: ThemeColors.textGrey,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await dataService.deleteEmergencyContact(contact.id);
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                      setState(() {});
                                                    }
                                                  },
                                                  child: Text(
                                                    loc.t('common.remove'),
                                                    style: const TextStyle(
                                                      color: ThemeColors.pastelRed,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    Divider(
                      color: ThemeColors.textGrey.withValues(alpha: 0.2),
                      thickness: 1,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Sabit Acil Durum Numaraları Başlığı
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      loc.t('emergency.contacts.default'),
                      style: const TextStyle(
                        color: ThemeColors.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Sabit Numaralar
                  _EmergencyCard(
                    number: '112',
                    title: loc.t('emergency.numbers.112'),
                    description: loc.t('emergency.numbers.112.desc'),
                    icon: Icons.local_hospital_outlined,
                    color: ThemeColors.pastelRed,
                    onCall: () => _makeCall(context, loc, '112'),
                  ),
                  const SizedBox(height: 12),
                  _EmergencyCard(
                    number: '110',
                    title: loc.t('emergency.numbers.110'),
                    description: loc.t('emergency.numbers.110.desc'),
                    icon: Icons.local_fire_department_outlined,
                    color: const Color(0xFFFF6B35),
                    onCall: () => _makeCall(context, loc, '110'),
                  ),
                  const SizedBox(height: 12),
                  _EmergencyCard(
                    number: '155',
                    title: loc.t('emergency.numbers.155'),
                    description: loc.t('emergency.numbers.155.desc'),
                    icon: Icons.shield_outlined,
                    color: ThemeColors.pastelBlue,
                    onCall: () => _makeCall(context, loc, '155'),
                  ),
                  const SizedBox(height: 12),
                  _EmergencyCard(
                    number: '156',
                    title: loc.t('emergency.numbers.156'),
                    description: loc.t('emergency.numbers.156.desc'),
                    icon: Icons.security_outlined,
                    color: const Color(0xFF4ECDC4),
                    onCall: () => _makeCall(context, loc, '156'),
                  ),
                  const SizedBox(height: 12),
                  _EmergencyCard(
                    number: '122',
                    title: loc.t('emergency.numbers.122'),
                    description: loc.t('emergency.numbers.122.desc'),
                    icon: Icons.crisis_alert_outlined,
                    color: ThemeColors.pastelYellow,
                    onCall: () => _makeCall(context, loc, '122'),
                  ),
                  const SizedBox(height: 12),
                  _EmergencyCard(
                    number: '114',
                    title: loc.t('emergency.numbers.114'),
                    description: loc.t('emergency.numbers.114.desc'),
                    icon: Icons.medication_outlined,
                    color: ThemeColors.pastelPurple,
                    onCall: () => _makeCall(context, loc, '114'),
                  ),
                  const SizedBox(height: 12),
                  _EmergencyCard(
                    number: '158',
                    title: loc.t('emergency.numbers.158'),
                    description: loc.t('emergency.numbers.158.desc'),
                    icon: Icons.sailing_outlined,
                    color: const Color(0xFF45B7D1),
                    onCall: () => _makeCall(context, loc, '158'),
                  ),
                  const SizedBox(height: 12),
                  _EmergencyCard(
                    number: '186',
                    title: loc.t('emergency.numbers.186'),
                    description: loc.t('emergency.numbers.186.desc'),
                    icon: Icons.power_outlined,
                    color: const Color(0xFFFFA07A),
                    onCall: () => _makeCall(context, loc, '186'),
                  ),
                  const SizedBox(height: 12),
                  _EmergencyCard(
                    number: '185',
                    title: loc.t('emergency.numbers.185'),
                    description: loc.t('emergency.numbers.185.desc'),
                    icon: Icons.water_drop_outlined,
                    color: const Color(0xFF64B5F6),
                    onCall: () => _makeCall(context, loc, '185'),
                  ),
                  const SizedBox(height: 12),
                  _EmergencyCard(
                    number: '187',
                    title: loc.t('emergency.numbers.187'),
                    description: loc.t('emergency.numbers.187.desc'),
                    icon: Icons.gas_meter_outlined,
                    color: const Color(0xFFFFB74D),
                    onCall: () => _makeCall(context, loc, '187'),
                  ),
                  const SizedBox(height: 80),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(
          current: AppNavItem.emergency,
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onCall;

  const _EmergencyCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onCall,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            number,
                            style: TextStyle(
                              color: color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            title,
                            style: const TextStyle(
                              color: ThemeColors.textWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: ThemeColors.textGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Call icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
