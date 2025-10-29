import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/app_bottom_navigation.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocalizationService, DataService>(
      builder: (context, loc, data, child) {
        final int totalBags = data.totalBagCount;
        final int totalProducts = data.totalProductCount;
        final int expiringCount = data.expiringProductCount;
        final int expiredCount = data.expiredProductCount;
        final int outOfStockCount = data.outOfStockProductCount;

        final bool hasCritical = expiredCount > 0 || outOfStockCount > 0;
        final bool hasExpiring = expiringCount > 0;

        final String criticalTitle = hasCritical
            ? loc.t('home.alerts.critical')
            : loc.t('home.alerts.safe');
        final String criticalDescription = hasCritical
            ? loc.t('home.alerts.critical.description', {
                'expired': expiredCount.toString(),
                'outOfStock': outOfStockCount.toString(),
              })
            : loc.t('home.alerts.safe.description');

        final String expiringDescription = hasExpiring
            ? loc.t('home.alerts.expiring.description', {
                'count': expiringCount.toString(),
              })
            : loc.t('home.alerts.empty');

        final expiredProducts = data.getExpiredProducts();
        final expiringProducts = data.getExpiringProducts();

        return Scaffold(
          backgroundColor: ThemeColors.bg1,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.t('home.header'),
                      style: const TextStyle(
                        color: ThemeColors.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: ThemeColors.textWhite,
                            size: 26,
                          ),
                          onPressed: () => _openAlertsSheet(
                            context,
                            loc,
                            data,
                            expiredProducts,
                            expiringProducts,
                          ),
                        ),
                        if (hasCritical || hasExpiring)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.9, end: 1.1)
                                  .animate(
                                    CurvedAnimation(
                                      parent: _pulseController,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: ThemeColors.pastelRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AlertCard(
                    title: criticalTitle,
                    description: criticalDescription,
                    colors: hasCritical
                        ? const [ThemeColors.pastelRed, Color(0xFFFF6B6B)]
                        : const [ThemeColors.pastelGreen, Color(0xFF4CE68A)],
                    icon: hasCritical
                        ? Icons.warning_amber_rounded
                        : Icons.verified_outlined,
                    iconColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  _ExpiringCard(
                    title: loc.t('home.alerts.expiring'),
                    description: expiringDescription,
                    highlight: hasExpiring,
                  ),

                  const SizedBox(height: 24),
                  Text(
                    loc.t('home.overview.title'),
                    style: const TextStyle(
                      color: ThemeColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: totalProducts.toString(),
                          label: loc.t('home.stats.products'),
                          icon: Icons.inventory_2_outlined,
                          accent: ThemeColors.pastelBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: totalBags.toString(),
                          label: loc.t('home.stats.bags'),
                          icon: Icons.backpack_outlined,
                          accent: ThemeColors.pastelPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: expiringCount.toString(),
                          label: loc.t('home.stats.expiring'),
                          icon: Icons.hourglass_top_outlined,
                          accent: ThemeColors.pastelYellow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: expiredCount.toString(),
                          label: loc.t('home.stats.expired'),
                          icon: Icons.error_outline,
                          accent: ThemeColors.pastelRed,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text(
                    loc.t('home.quickActions'),
                    style: const TextStyle(
                      color: ThemeColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.add,
                          label: loc.t('home.quickActions.addProduct'),
                          color: ThemeColors.primaryGreen,
                          onTap: () =>
                              Navigator.pushNamed(context, '/yeni-urun'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.photo_camera_outlined,
                          label: loc.t('home.quickActions.capture'),
                          color: ThemeColors.pastelBlue,
                          onTap: () =>
                              Navigator.pushNamed(context, '/barkod-tara'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.inventory_2,
                          label: loc.t('home.quickActions.inventory'),
                          color: ThemeColors.primaryPurple,
                          onTap: () => Navigator.pushNamed(context, '/urunler'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const AppBottomNavigation(
            current: AppNavItem.home,
          ),
        );
      },
    );
  }

  void _openAlertsSheet(
    BuildContext context,
    LocalizationService loc,
    DataService data,
    List<Product> expired,
    List<Product> expiring,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ThemeColors.bg3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final hasAlerts = expired.isNotEmpty || expiring.isNotEmpty;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.t('home.alerts.modalTitle'),
                      style: const TextStyle(
                        color: ThemeColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: ThemeColors.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!hasAlerts)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        loc.t('home.alerts.empty'),
                        style: const TextStyle(
                          color: ThemeColors.textGrey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else ...[
                  if (expired.isNotEmpty)
                    _AlertListSection(
                      title: loc.t('home.stats.expired'),
                      items: expired,
                      icon: Icons.error_outline,
                      accent: ThemeColors.pastelRed,
                      loc: loc,
                      data: data,
                    ),
                  if (expiring.isNotEmpty)
                    _AlertListSection(
                      title: loc.t('home.stats.expiring'),
                      items: expiring,
                      icon: Icons.hourglass_top,
                      accent: ThemeColors.pastelYellow,
                      loc: loc,
                      data: data,
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.title,
    required this.description,
    required this.colors,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String description;
  final List<Color> colors;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiringCard extends StatelessWidget {
  const _ExpiringCard({
    required this.title,
    required this.description,
    required this.highlight,
  });

  final String title;
  final String description;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ThemeColors.pastelYellow, Color(0xFFFFD166)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.hourglass_top,
              color: Colors.black.withValues(alpha: 0.85),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.75),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (highlight)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.bgCardDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: ThemeColors.textWhite, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ThemeColors.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertListSection extends StatelessWidget {
  const _AlertListSection({
    required this.title,
    required this.items,
    required this.icon,
    required this.accent,
    required this.loc,
    required this.data,
  });

  final String title;
  final List<Product> items;
  final IconData icon;
  final Color accent;
  final LocalizationService loc;
  final DataService data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: ThemeColors.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (product) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: ThemeColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.resolveCategoryLabel(product.categoryId, loc),
                          style: const TextStyle(
                            color: ThemeColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: accent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
