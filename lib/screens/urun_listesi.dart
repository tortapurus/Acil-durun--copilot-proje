import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../services/settings_service.dart';
import '../theme/theme_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';

enum DaysFilter { all, expiringSoon, expired }
enum NameSort { az, za }

class UrunListesi extends StatefulWidget {
  const UrunListesi({super.key});

  @override
  State<UrunListesi> createState() => _UrunListesiState();
}

class _UrunListesiState extends State<UrunListesi> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String? _selectedCategoryId;
  DaysFilter _selectedDaysFilter = DaysFilter.all;
  NameSort _selectedNameSort = NameSort.az;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleBackNavigation(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _openCategorySheet(
    BuildContext context,
    LocalizationService loc,
    DataService data,
  ) {
    final categories = List.of(data.allCategories)
      ..sort(
        (a, b) => data
            .resolveCategoryLabel(a.id, loc)
            .toLowerCase()
            .compareTo(
              data.resolveCategoryLabel(b.id, loc).toLowerCase(),
            ),
      );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ThemeColors.bg3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.t('products.filter.category.title'),
                        style: const TextStyle(
                          color: ThemeColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
              ),
              ListTile(
                title: Text(
                  loc.t('products.filter.category.all'),
                  style: const TextStyle(color: ThemeColors.textWhite),
                ),
                trailing: _selectedCategoryId == null
                    ? const Icon(Icons.check, color: ThemeColors.pastelGreen)
                    : null,
                onTap: () {
                  setState(() => _selectedCategoryId = null);
                  Navigator.pop(context);
                },
              ),
              if (categories.isNotEmpty)
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: ThemeColors.bg2,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final bool isSelected = category.id == _selectedCategoryId;
                      return ListTile(
                        title: Text(
                          data.resolveCategoryLabel(category.id, loc),
                          style: const TextStyle(color: ThemeColors.textWhite),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check,
                                color: ThemeColors.pastelGreen,
                              )
                            : null,
                        onTap: () {
                          setState(() => _selectedCategoryId = category.id);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ListTile(
                title: Text(
                  loc.t('products.filter.category.clear'),
                  style: const TextStyle(color: ThemeColors.textGrey),
                ),
                onTap: () {
                  setState(() => _selectedCategoryId = null);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDaysSheet(BuildContext context, LocalizationService loc) {
    final options = DaysFilter.values;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ThemeColors.bg3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.t('products.filter.days.title'),
                        style: const TextStyle(
                          color: ThemeColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
              ),
              ...options.map((filter) {
                final bool isSelected = filter == _selectedDaysFilter;
                return ListTile(
                  title: Text(
                    _daysFilterLabel(loc, filter),
                    style: const TextStyle(color: ThemeColors.textWhite),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: ThemeColors.pastelGreen)
                      : null,
                  onTap: () {
                    setState(() => _selectedDaysFilter = filter);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _toggleNameSort() {
    setState(() {
      _selectedNameSort =
          _selectedNameSort == NameSort.az ? NameSort.za : NameSort.az;
    });
  }

  String _categoryChipLabel(LocalizationService loc, DataService data) {
    if (_selectedCategoryId == null) {
      return loc.t('products.category');
    }
    final label = data.resolveCategoryLabel(_selectedCategoryId!, loc);
    return '${loc.t('products.category')}: $label';
  }

  String _daysFilterLabel(LocalizationService loc, [DaysFilter? filter]) {
    final DaysFilter effectiveFilter = filter ?? _selectedDaysFilter;
    switch (effectiveFilter) {
      case DaysFilter.all:
        return loc.t('products.filter.days.all');
      case DaysFilter.expiringSoon:
        return loc.t('products.filter.days.expiringSoon');
      case DaysFilter.expired:
        return loc.t('products.filter.days.expired');
    }
  }

  String _nameSortLabel(LocalizationService loc) {
    return _selectedNameSort == NameSort.az
        ? loc.t('products.filter.name.az')
        : loc.t('products.filter.name.za');
  }

  List<Product> _buildProductList(DataService data, LocalizationService loc) {
    final query = _searchController.text.trim().toLowerCase();
    List<Product> results = data.products.toList();

    if (_selectedCategoryId != null) {
      results = results
          .where((product) => product.categoryId == _selectedCategoryId)
          .toList();
    }

    switch (_selectedDaysFilter) {
      case DaysFilter.all:
        break;
      case DaysFilter.expiringSoon:
        results = results.where((product) => product.isExpiringsSoon).toList();
        break;
      case DaysFilter.expired:
        results = results.where((product) => product.isExpired).toList();
        break;
    }

    if (query.isNotEmpty) {
      results = results
          .where(
            (product) {
              final categoryLabel =
                  data.resolveCategoryLabel(product.categoryId, loc);
              return product.name.toLowerCase().contains(query) ||
                  categoryLabel.toLowerCase().contains(query);
            },
          )
          .toList();
    }

    if (_selectedDaysFilter == DaysFilter.expiringSoon ||
        _selectedDaysFilter == DaysFilter.expired) {
      results.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    } else {
      results.sort((a, b) => _selectedNameSort == NameSort.az
          ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
          : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    }

    return results;
  }

  void _resetFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedDaysFilter = DaysFilter.all;
      _selectedNameSort = NameSort.az;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LocalizationService, DataService, SettingsService>(
      builder: (context, loc, data, settings, child) {
        final List<Product> products = _buildProductList(data, loc);
        final colors = AppThemeColors.read(context);

        return Scaffold(
          backgroundColor: colors.bg1,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: loc.t('common.back'),
                        onPressed: () => _handleBackNavigation(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: ThemeColors.textWhite,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          loc.t('products.title'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: ThemeColors.textWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: loc.t('add.item'),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/yeni-urun',
                        ),
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: ThemeColors.pastelGreen,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.bgCard,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      cursorColor: ThemeColors.pastelGreen,
                      style: const TextStyle(color: ThemeColors.textWhite),
                      decoration: InputDecoration(
                        hintText: loc.t('products.search'),
                        hintStyle: const TextStyle(color: ThemeColors.textGrey),
                        prefixIcon: const Icon(Icons.search,
                            color: ThemeColors.textGrey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () => _searchController.clear(),
                                icon: const Icon(
                                  Icons.close,
                                  color: ThemeColors.textGrey,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: ThemeColors.pastelGreen,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _FilterPill(
                        label: _categoryChipLabel(loc, data),
                        isActive: _selectedCategoryId != null,
                        onTap: () =>
                            _openCategorySheet(context, loc, data),
                        icon: Icons.chevron_right,
                      ),
                      _FilterPill(
                        label: _daysFilterLabel(loc),
                        isActive: _selectedDaysFilter != DaysFilter.all,
                        onTap: () => _openDaysSheet(context, loc),
                        icon: Icons.schedule,
                      ),
                      _FilterPill(
                        label: _nameSortLabel(loc),
                        isActive: _selectedNameSort == NameSort.za,
                        onTap: _toggleNameSort,
                        icon: Icons.sort_by_alpha,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: products.isEmpty
                      ? _EmptyProductsPlaceholder(
                          title: loc.t('products.empty.title'),
                          subtitle: loc.t('products.empty.description'),
                          actionLabel: loc.t('add.item'),
                          resetLabel: loc.t('products.filter.reset'),
                          onActionTap: () => Navigator.pushNamed(
                            context,
                            '/yeni-urun',
                          ),
                          onResetFilters: _resetFilters,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: products.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final categoryLabel =
                                data.resolveCategoryLabel(product.categoryId, loc);
                            return _ProductCard(
                              product: product,
                              loc: loc,
                              categoryLabel: categoryLabel,
                              showImages: settings.showProductImages,
                              palette: colors,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/urun-detay',
                                arguments: product.id,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNavigation(
            current: AppNavItem.products,
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.loc,
    required this.categoryLabel,
    required this.showImages,
    required this.palette,
    this.onTap,
  });

  final Product product;
  final LocalizationService loc;
  final String categoryLabel;
  final bool showImages;
  final AppThemeColors palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isExpired = product.isExpired;
    final bool isExpiringSoon = product.isExpiringsSoon;
    final bool isOutOfStock = product.stock <= 0;

    final List<_StatusBadge> badges = [];
    if (isExpired) {
      badges.add(_StatusBadge(loc.t('status.expired'), ThemeColors.pastelRed));
    } else if (isExpiringSoon) {
      badges.add(
        _StatusBadge(loc.t('status.expiry_approaching'), ThemeColors.pastelYellow),
      );
    }
    if (isOutOfStock) {
      badges.add(_StatusBadge(loc.t('status.missing'), ThemeColors.pastelPurple));
    }

    final String? imagePath = product.imagePath;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: palette.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: palette.bg2.withValues(alpha: 0.6),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showImages) ...[
              _ProductImage(imagePath: imagePath),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: ThemeColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categoryLabel,
                    style: const TextStyle(
                      color: ThemeColors.textGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (badges.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: badges
                          .map((badge) => _StatusChip(badge: badge))
                          .toList(),
                    ),
                  if (badges.isNotEmpty) const SizedBox(height: 8),
                  Text(
                    isExpired
                        ? loc.t('expired')
                        : '${loc.t('products.remaining_days')}: ${product.daysRemaining}',
                    style: TextStyle(
                      color: isExpired
                          ? ThemeColors.pastelRed
                          : ThemeColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loc.t('products.stock')}: ${product.stock}',
                    style: TextStyle(
                      color: isOutOfStock
                          ? ThemeColors.pastelRed
                          : ThemeColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('http')) {
        child = Image.network(
          imagePath!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.inventory_2_outlined,
            color: ThemeColors.textGrey,
          ),
        );
      } else if (File(imagePath!).existsSync()) {
        child = Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.inventory_2_outlined,
            color: ThemeColors.textGrey,
          ),
        );
      } else {
        child = const Icon(
          Icons.inventory_2_outlined,
          color: ThemeColors.textGrey,
        );
      }
    } else {
      child = const Icon(
        Icons.inventory_2_outlined,
        color: ThemeColors.textGrey,
      );
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: ThemeColors.bg2,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: ThemeColors.pastelGreen.withValues(alpha: 0.2),
        ),
      ),
      child: ClipOval(child: child),
    );
  }
}

class _StatusBadge {
  const _StatusBadge(this.label, this.color);

  final String label;
  final Color color;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.badge});

  final _StatusBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
  color: badge.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        badge.label,
        style: TextStyle(
          color: badge.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
      color: isActive
        ? ThemeColors.pastelGreen.withValues(alpha: 0.15)
        : ThemeColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
      color: isActive
        ? ThemeColors.pastelGreen
        : ThemeColors.bg2.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: ThemeColors.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, color: ThemeColors.pastelGreen, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyProductsPlaceholder extends StatelessWidget {
  const _EmptyProductsPlaceholder({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.resetLabel,
    required this.onActionTap,
    required this.onResetFilters,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final String resetLabel;
  final VoidCallback onActionTap;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: ThemeColors.textGrey,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ThemeColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ThemeColors.textGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.pastelGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: onActionTap,
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onResetFilters,
              child: Text(
                resetLabel,
                style: const TextStyle(color: ThemeColors.textGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
