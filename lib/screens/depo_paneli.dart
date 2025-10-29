import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/depot.dart';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/app_bottom_navigation.dart';

class DepoPaneli extends StatelessWidget {
  const DepoPaneli({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocalizationService, DataService>(
      builder: (context, loc, data, child) {
        final List<Depot> depots = data.depots;
        final List<Product> depotProducts = data.products
            .where((product) => product.storageType == StorageLocationType.depot)
            .toList();

        final int totalDepotProducts = depotProducts.length;
        final int expiringSoonCount = depotProducts
            .where((product) => product.isExpiringsSoon)
            .length;
        final int expiredCount = depotProducts
            .where((product) => product.isExpired)
            .length;
        final int lowStockCount = depotProducts
            .where((product) => product.stock <= 1)
            .length;

        return Scaffold(
          backgroundColor: ThemeColors.bg1,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(onCreateDepot: () => _showCreateDepotSheet(context, loc, data), loc: loc),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _SummarySection(
                          totalProducts: totalDepotProducts,
                          expiringSoon: expiringSoonCount,
                          expired: expiredCount,
                          lowStock: lowStockCount,
                          loc: loc,
                        ),
                        const SizedBox(height: 24),
                        _ActionGrid(
                          onCreateDepot: () => _showCreateDepotSheet(context, loc, data),
                          loc: loc,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          loc.t('depot.areas'),
                          style: const TextStyle(
                            color: ThemeColors.textWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (depots.isEmpty)
                          _EmptyDepotState(
                            loc: loc,
                            onCreate: () => _showCreateDepotSheet(context, loc, data),
                          )
                        else
                          Column(
                            children: depots
                                .map(
                                  (depot) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _DepotCard(
                                      depot: depot,
                                      products: data.getProductsInDepot(depot.id),
                                      loc: loc,
                                      data: data,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNavigation(
            current: AppNavItem.depot,
          ),
        );
      },
    );
  }

  void _showCreateDepotSheet(
    BuildContext context,
    LocalizationService loc,
    DataService data,
  ) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeColors.bg3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.t('depot.create.button'),
                        style: const TextStyle(
                          color: ThemeColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(
                        Icons.close,
                        color: ThemeColors.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: ThemeColors.textWhite),
                  decoration: InputDecoration(
                    labelText: loc.t('depot.create.name'),
                    labelStyle: const TextStyle(color: ThemeColors.textGrey),
                    hintText: loc.t('depot.create.name_placeholder'),
                    hintStyle: const TextStyle(color: ThemeColors.textGrey),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return loc.t('form.error.required');
                    }
                    if (text.length < 2) {
                      return loc.t('newProduct.category.custom.error.length');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  style: const TextStyle(color: ThemeColors.textWhite),
                  decoration: InputDecoration(
                    labelText: loc.t('depot.create.notes'),
                    labelStyle: const TextStyle(color: ThemeColors.textGrey),
                    hintText: loc.t('depot.create.notes_placeholder'),
                    hintStyle: const TextStyle(color: ThemeColors.textGrey),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      final depot = Depot(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                      );

                      data.addDepot(depot);

                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            loc.t('depot.create.success', {'name': depot.name}),
                            style: const TextStyle(color: ThemeColors.textWhite),
                          ),
                          backgroundColor: ThemeColors.bg3,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.primaryPurple,
                      foregroundColor: ThemeColors.textWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(loc.t('common.add')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onCreateDepot,
    required this.loc,
  });

  final VoidCallback onCreateDepot;
  final LocalizationService loc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.t('depot.panel'),
                  style: const TextStyle(
                    color: ThemeColors.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.t('home.quickActions.inventory'),
                  style: const TextStyle(
                    color: ThemeColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: loc.t('home.quickActions.capture'),
            onPressed: () => Navigator.pushNamed(context, '/barkod-tara'),
            icon: const Icon(
              Icons.qr_code_scanner,
              color: ThemeColors.textWhite,
            ),
          ),
          IconButton(
            tooltip: loc.t('depot.create.button'),
            onPressed: onCreateDepot,
            icon: const Icon(
              Icons.add_box_outlined,
              color: ThemeColors.pastelGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.totalProducts,
    required this.expiringSoon,
    required this.expired,
    required this.lowStock,
    required this.loc,
  });

  final int totalProducts;
  final int expiringSoon;
  final int expired;
  final int lowStock;
  final LocalizationService loc;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                value: totalProducts.toString(),
                label: loc.t('home.stats.products'),
                accent: ThemeColors.pastelBlue,
                icon: Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                value: expiringSoon.toString(),
                label: loc.t('home.stats.expiring'),
                accent: ThemeColors.pastelYellow,
                icon: Icons.hourglass_top_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                value: expired.toString(),
                label: loc.t('home.stats.expired'),
                accent: ThemeColors.pastelRed,
                icon: Icons.error_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                value: lowStock.toString(),
                label: loc.t('home.stats.outOfStock'),
                accent: ThemeColors.pastelRed,
                icon: Icons.report_problem_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.onCreateDepot,
    required this.loc,
  });

  final VoidCallback onCreateDepot;
  final LocalizationService loc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.store_mall_directory_outlined,
            label: loc.t('depot.create.button'),
            color: ThemeColors.primaryGreen,
            onTap: onCreateDepot,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.qr_code_scanner,
            label: loc.t('home.quickActions.capture'),
            color: ThemeColors.pastelBlue,
            onTap: () => Navigator.pushNamed(context, '/barkod-tara'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.edit_note_outlined,
            label: loc.t('home.quickActions.inventory'),
            color: ThemeColors.primaryPurple,
            onTap: () => Navigator.pushNamed(context, '/urunler'),
          ),
        ),
      ],
    );
  }
}

class _EmptyDepotState extends StatelessWidget {
  const _EmptyDepotState({
    required this.loc,
    required this.onCreate,
  });

  final LocalizationService loc;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: ThemeColors.bgCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warehouse_outlined,
            color: ThemeColors.textGrey,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            loc.t('depot.panel'),
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            loc.t('products.empty.description'),
            style: const TextStyle(
              color: ThemeColors.textGrey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primaryGreen,
              foregroundColor: ThemeColors.textBlack,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(loc.t('depot.create.button')),
          ),
        ],
      ),
    );
  }
}

class _DepotCard extends StatelessWidget {
  const _DepotCard({
    required this.depot,
    required this.products,
    required this.loc,
    required this.data,
  });

  final Depot depot;
  final List<Product> products;
  final LocalizationService loc;
  final DataService data;

  @override
  Widget build(BuildContext context) {
    final int productCount = products.length;
    final int expiredCount = products.where((product) => product.isExpired).length;
    final int expiringSoonCount =
        products.where((product) => product.isExpiringsSoon).length;
    final int missingCount =
        products.where((product) => product.stock <= 0).length;

    final _DepotStatus status = _DepotStatus.resolve(
      expiredCount: expiredCount,
      expiringSoonCount: expiringSoonCount,
      missingCount: missingCount,
    );

    final List<Product> highlightedProducts = products.take(4).toList();

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: status.borderColor,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      depot.name,
                      style: const TextStyle(
                        color: ThemeColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (depot.notes != null && depot.notes!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        depot.notes!,
                        style: const TextStyle(
                          color: ThemeColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusChip(
                label: loc.t(status.labelKey),
                color: status.chipColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: ThemeColors.textGrey,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                loc.t('items.count', {'count': productCount.toString()}),
                style: const TextStyle(
                  color: ThemeColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (products.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...highlightedProducts.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DepotProductRow(
                  product: product,
                  loc: loc,
                  data: data,
                ),
              ),
            ),
          ]
          else ...[
            const SizedBox(height: 12),
            Text(
              loc.t('products.empty.title'),
              style: const TextStyle(
                color: ThemeColors.textGrey,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DepotProductRow extends StatelessWidget {
  const _DepotProductRow({
    required this.product,
    required this.loc,
    required this.data,
  });

  final Product product;
  final LocalizationService loc;
  final DataService data;

  @override
  Widget build(BuildContext context) {
    final String categoryLabel = data.resolveCategoryLabel(product.categoryId, loc);
    final bool isExpired = product.isExpired;
    final bool isExpiringSoon = product.isExpiringsSoon;

    final String expiryText;
    if (isExpired) {
      expiryText = loc.t('status.expired');
    } else if (isExpiringSoon) {
      expiryText = loc.t('status.expiry_approaching');
    } else {
      expiryText = '${product.daysRemaining} ${loc.t('products.remaining_days')}';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.pushNamed(
        context,
        '/urun-detay',
        arguments: {'productId': product.id},
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: ThemeColors.bg3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ThemeColors.bgCard,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.inventory_2_outlined,
                color: ThemeColors.textGrey,
                size: 20,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$categoryLabel • $expiryText',
                    style: const TextStyle(
                      color: ThemeColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${loc.t('products.stock')}: ${product.stock}',
                  style: const TextStyle(
                    color: ThemeColors.textWhite,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.value,
    required this.label,
    required this.accent,
    required this.icon,
  });

  final String value;
  final String label;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeColors.bgCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: ThemeColors.bgCard,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: ThemeColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
  color: color.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DepotStatus {
  const _DepotStatus({
    required this.labelKey,
    required this.chipColor,
    required this.borderColor,
  });

  final String labelKey;
  final Color chipColor;
  final Color borderColor;

  static _DepotStatus resolve({
    required int expiredCount,
    required int expiringSoonCount,
    required int missingCount,
  }) {
    if (expiredCount > 0) {
      return const _DepotStatus(
        labelKey: 'status.expired',
        chipColor: ThemeColors.pastelRed,
        borderColor: ThemeColors.pastelRed,
      );
    }

    if (missingCount > 0) {
      return const _DepotStatus(
        labelKey: 'status.missing',
        chipColor: ThemeColors.pastelRed,
        borderColor: ThemeColors.pastelRed,
      );
    }

    if (expiringSoonCount > 0) {
      return const _DepotStatus(
        labelKey: 'status.expiry_approaching',
        chipColor: ThemeColors.pastelYellow,
        borderColor: ThemeColors.pastelYellow,
      );
    }

    return const _DepotStatus(
      labelKey: 'status.current',
      chipColor: ThemeColors.pastelGreen,
      borderColor: ThemeColors.pastelGreen,
    );
  }
}
