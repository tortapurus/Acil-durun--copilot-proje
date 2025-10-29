import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/localization_service.dart';
import '../theme/theme_colors.dart';
import '../theme/app_theme.dart';

enum AppNavItem {
  home,
  bags,
  depot,
  products,
  settings,
  info,
}

class _NavConfig {
  const _NavConfig({
    required this.item,
    required this.icon,
    required this.labelKey,
    required this.route,
  });

  final AppNavItem item;
  final IconData icon;
  final String labelKey;
  final String route;
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.current,
  });

  final AppNavItem current;

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, loc, _) {
        // Order adjusted: info moved before settings, settings placed to the far right
        final navItems = <_NavConfig>[
          _NavConfig(
            item: AppNavItem.home,
            icon: Icons.home_outlined,
            labelKey: 'nav.home',
            route: '/',
          ),
          _NavConfig(
            item: AppNavItem.bags,
            icon: Icons.backpack_outlined,
            labelKey: 'nav.bags',
            route: '/acil-durum',
          ),
          _NavConfig(
            item: AppNavItem.depot,
            icon: Icons.warehouse_outlined,
            labelKey: 'nav.depot',
            route: '/depo',
          ),
          _NavConfig(
            item: AppNavItem.products,
            icon: Icons.inventory_2_outlined,
            labelKey: 'nav.products',
            route: '/urunler',
          ),
          // swap: show info before settings so settings becomes the last item
          _NavConfig(
            item: AppNavItem.info,
            icon: Icons.info_outline,
            labelKey: 'nav.info',
            route: '/bilgi',
          ),
          _NavConfig(
            item: AppNavItem.settings,
            icon: Icons.settings_outlined,
            labelKey: 'nav.settings',
            route: '/ayarlar',
          ),
        ];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? ThemeColors.bgCard,
            border: Border(
              top: BorderSide(
                color: AppThemeColors.read(context).navigationBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: navItems.map((item) {
              final bool isActive = item.item == current;
              final Color labelColor = isActive
                  ? ThemeColors.pastelGreen
                  : ThemeColors.textGrey;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (isActive) return;
                    Navigator.pushReplacementNamed(
                      context,
                      item.route,
                      arguments: item.item,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: labelColor,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.t(item.labelKey),
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 11,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
