import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/localization_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/app_bottom_navigation.dart';

class AcilDurumNumaralari extends StatelessWidget {
  const AcilDurumNumaralari({super.key});

  static const List<_EmergencyContact> _contacts = <_EmergencyContact>[
    _EmergencyContact(
      number: '112',
      descriptionKey: 'emergency.numbers.112',
      accent: Color(0xFFE53935),
    ),
    _EmergencyContact(
      number: '110',
      descriptionKey: 'emergency.numbers.110',
      accent: Color(0xFFE53935),
    ),
    _EmergencyContact(
      number: '155',
      descriptionKey: 'emergency.numbers.155',
      accent: Color(0xFF47B4EB),
    ),
    _EmergencyContact(
      number: '156',
      descriptionKey: 'emergency.numbers.156',
      accent: Color(0xFF47B4EB),
    ),
    _EmergencyContact(
      number: '114',
      descriptionKey: 'emergency.numbers.114',
      accent: Color(0xFF66BB6A),
    ),
    _EmergencyContact(
      number: '122',
      descriptionKey: 'emergency.numbers.122',
      accent: Color(0xFFE53935),
    ),
    _EmergencyContact(
      number: '158',
      descriptionKey: 'emergency.numbers.158',
      accent: Color(0xFF47B4EB),
    ),
    _EmergencyContact(
      number: '186',
      descriptionKey: 'emergency.numbers.186',
      accent: Color(0xFFFFA726),
    ),
    _EmergencyContact(
      number: '185',
      descriptionKey: 'emergency.numbers.185',
      accent: Color(0xFF42A5F5),
    ),
    _EmergencyContact(
      number: '187',
      descriptionKey: 'emergency.numbers.187',
      accent: Color(0xFFAB47BC),
    ),
    _EmergencyContact(
      number: '175',
      descriptionKey: 'emergency.numbers.175',
      accent: Color(0xFF78909C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, loc, _) {
        return Scaffold(
          backgroundColor: ThemeColors.bg1,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: ThemeColors.textWhite),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              loc.t('emergency.numbers'),
              style: const TextStyle(
                color: ThemeColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          loc.t('emergency.numbers.general'),
                          style: const TextStyle(
                            color: ThemeColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: loc.t('common.add'),
                        onPressed: () {
                          final messenger = ScaffoldMessenger.of(context);
                          messenger
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  loc.t('emergency.numbers.addPlaceholder'),
                                ),
                                backgroundColor: ThemeColors.bg3,
                              ),
                            );
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: ThemeColors.pastelBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      int crossAxisCount = 3;
                      if (width >= 720) {
                        crossAxisCount = 4;
                      } else if (width < 360) {
                        crossAxisCount = 2;
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final _EmergencyContact contact = _contacts[index];
                          return _ContactCard(
                            contact: contact,
                            description: loc.t(contact.descriptionKey),
                            onTap: () => _launchNumber(context, loc, contact.number),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const AppBottomNavigation(
            current: AppNavItem.settings,
          ),
        );
      },
    );
  }

  Future<void> _launchNumber(
    BuildContext context,
    LocalizationService loc,
    String number,
  ) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      messenger.clearSnackBars();

      if (launched) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              loc.t('emergency.numbers.calling', {'number': number}),
            ),
            backgroundColor: ThemeColors.bg3,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(loc.t('emergency.numbers.error')),
            backgroundColor: ThemeColors.pastelRed,
          ),
        );
      }
    } catch (_) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(loc.t('emergency.numbers.error')),
            backgroundColor: ThemeColors.pastelRed,
          ),
        );
    }
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.description,
    required this.onTap,
  });

  final _EmergencyContact contact;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: contact.accent.withValues(alpha: 0.28),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              contact.number,
              style: TextStyle(
                color: contact.accent,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: ThemeColors.textGrey,
                fontSize: 12,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyContact {
  const _EmergencyContact({
    required this.number,
    required this.descriptionKey,
    required this.accent,
  });

  final String number;
  final String descriptionKey;
  final Color accent;
}
