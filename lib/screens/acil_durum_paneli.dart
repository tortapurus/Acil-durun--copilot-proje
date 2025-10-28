import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bag.dart';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/app_bottom_navigation.dart';

class AcilDurumPaneli extends StatelessWidget {
  const AcilDurumPaneli({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocalizationService, DataService>(
      builder: (context, loc, data, child) {
        final List<Bag> bags = data.bags;
        final List<Product> expiredProducts = data.getExpiredProducts();
        final List<Product> expiringProducts = data.getExpiringProducts();
        final List<Product> outOfStockProducts =
            data.products.where((product) => product.stock <= 0).toList();

        final bool hasAlerts = expiredProducts.isNotEmpty ||
            expiringProducts.isNotEmpty ||
            outOfStockProducts.isNotEmpty;

        return Scaffold(
          backgroundColor: ThemeColors.bg1,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          loc.t('emergencyPanel.header'),
                          style: const TextStyle(
                            color: ThemeColors.textWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _NotificationButton(
                        hasAlerts: hasAlerts,
                        onTap: () => _openAlertsSheet(
                          context,
                          loc,
                          data,
                          expiredProducts,
                          expiringProducts,
                          outOfStockProducts,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: loc.t('bags.title'),
                    trailing: IconButton(
                      tooltip: loc.t('bag.create.button'),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/yeni-canta',
                      ),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: ThemeColors.pastelGreen,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (bags.isEmpty)
                    _EmptyState(message: loc.t('bags.empty'))
                  else
                    Column(
                      children: bags.map((bag) {
                        final bagProducts = data.getProductsInBag(bag.id);
                        final int totalCount = bagProducts.length;
                        final int expiredCount = bagProducts
                            .where((product) => product.isExpired)
                            .length;
                        final int expiringCount = bagProducts
                            .where((product) =>
                                product.isExpiringsSoon && !product.isExpired)
                            .length;
                        final int missingCount = bagProducts
                            .where((product) => product.stock <= 0)
                            .length;

                        final chips = _buildStatusChips(
                          loc,
                          expiredCount: expiredCount,
                          expiringCount: expiringCount,
                          missingCount: missingCount,
                        );

                        final Color accentColor = _resolveAccent(chips);

                        final List<String> details = [
                          if (expiredCount > 0)
                            '${loc.t('status.expired')}: $expiredCount',
                          if (expiringCount > 0)
                            '${loc.t('status.expiry_approaching')}: $expiringCount',
                          if (missingCount > 0)
                            '${loc.t('status.missing')}: $missingCount',
                        ];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _StatusCard(
                            title: bag.name,
                            subtitle: loc.t(
                              'items.count',
                              {'count': totalCount.toString()},
                            ),
                            chips: chips,
                            details: details,
                            accent: accentColor,
                            icon: Icons.backpack_outlined,
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 32),
                  _SectionHeader(
                    title: loc.t('depot.panel'),
                    trailing: IconButton(
                      tooltip: loc.t('depot.create.button'),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/depo',
                      ),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: ThemeColors.pastelGreen,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (_) {
                      final int totalProducts = data.totalProductCount;
                      final int expiredCount = data.expiredProductCount;
                      final int expiringCount = data.expiringProductCount;
                      final int outOfStockCount = data.outOfStockProductCount;

                      final chips = _buildStatusChips(
                        loc,
                        expiredCount: expiredCount,
                        expiringCount: expiringCount,
                        missingCount: outOfStockCount,
                      );

                      final Color accentColor = _resolveAccent(chips);

                      final List<String> details = [
                        if (expiredCount > 0)
                          '${loc.t('status.expired')}: $expiredCount',
                        if (expiringCount > 0)
                          '${loc.t('status.expiry_approaching')}: $expiringCount',
                        if (outOfStockCount > 0)
                          '${loc.t('home.stats.outOfStock')}: $outOfStockCount',
                      ];

                      return _StatusCard(
                        title: loc.t('depot.main'),
                        subtitle: loc.t(
                          'items.count',
                          {'count': totalProducts.toString()},
                        ),
                        chips: chips,
                        details: details,
                        accent: accentColor,
                        icon: Icons.warehouse_outlined,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const AppBottomNavigation(
            current: AppNavItem.bags,
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
    List<Product> outOfStock,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ThemeColors.bg3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final bool hasAlerts = expired.isNotEmpty ||
            expiring.isNotEmpty ||
            outOfStock.isNotEmpty;
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
                  if (outOfStock.isNotEmpty)
                    _AlertListSection(
                      title: loc.t('home.stats.outOfStock'),
                      items: outOfStock,
                      icon: Icons.inventory_2_outlined,
                      accent: ThemeColors.pastelPurple,
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

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.hasAlerts,
    required this.onTap,
  });

  final bool hasAlerts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(
            Icons.notifications_outlined,
            color: ThemeColors.textWhite,
            size: 26,
          ),
        ),
        if (hasAlerts)
          const Positioned(
            right: 6,
            top: 6,
            child: _NotificationDot(),
          ),
      ],
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: ThemeColors.pastelRed,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.details,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<_StatusChipData> chips;
  final List<String> details;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ThemeColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: ThemeColors.textGrey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: chips
                      .map((chip) => _StatusChip(data: chip))
                      .toList(),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: details
                        .map(
                          (detail) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              detail,
                              style: const TextStyle(
                                color: ThemeColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.data});

  final _StatusChipData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        data.label,
        style: TextStyle(
          color: data.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChipData {
  const _StatusChipData({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}

List<_StatusChipData> _buildStatusChips(
  LocalizationService loc, {
  required int expiredCount,
  required int expiringCount,
  required int missingCount,
}) {
  final List<_StatusChipData> chips = [];

  if (expiredCount > 0) {
    chips.add(
      _StatusChipData(
        label: loc.t('status.expired'),
        color: ThemeColors.pastelRed,
      ),
    );
  }

  if (expiringCount > 0) {
    chips.add(
      _StatusChipData(
        label: loc.t('status.expiry_approaching'),
        color: ThemeColors.pastelYellow,
      ),
    );
  }

  if (missingCount > 0) {
    chips.add(
      _StatusChipData(
        label: loc.t('status.missing'),
        color: ThemeColors.pastelPurple,
      ),
    );
  }

  if (chips.isEmpty) {
    chips.add(
      _StatusChipData(
        label: loc.t('status.current'),
        color: ThemeColors.pastelGreen,
      ),
    );
  }

  return chips;
}

Color _resolveAccent(List<_StatusChipData> chips) {
  if (chips.any((chip) => chip.color == ThemeColors.pastelRed)) {
    return ThemeColors.pastelRed;
  }
  if (chips.any((chip) => chip.color == ThemeColors.pastelYellow)) {
    return ThemeColors.pastelYellow;
  }
  if (chips.any((chip) => chip.color == ThemeColors.pastelPurple)) {
    return ThemeColors.pastelPurple;
  }
  return ThemeColors.pastelGreen;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColors.pastelGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.backpack_outlined,
            color: ThemeColors.textGrey,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ThemeColors.textGrey,
              fontSize: 14,
            ),
          ),
        ],
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
          Text(
            '$title (${items.length})',
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (product) => _ProductAlertTile(
              product: product,
              icon: icon,
              accent: accent,
              loc: loc,
              data: data,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductAlertTile extends StatelessWidget {
  const _ProductAlertTile({
    required this.product,
    required this.icon,
    required this.accent,
    required this.loc,
    required this.data,
  });

  final Product product;
  final IconData icon;
  final Color accent;
  final LocalizationService loc;
  final DataService data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.bg2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
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
        ],
      ),
    );
  }
}
