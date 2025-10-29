import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../theme/theme_colors.dart';

class DepoDetay extends StatelessWidget {
  const DepoDetay({super.key, required this.depotId});

  final String? depotId;

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();
    final data = context.watch<DataService>();

  final depot = depotId == null ? null : data.getDepotById(depotId!);
  final List<Product> products = depotId == null ? [] : data.getProductsInDepot(depotId!);
  final String? notes = depot?.notes;

    return Scaffold(
      backgroundColor: ThemeColors.bg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(depot?.name ?? loc.t('depot.panel')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notes != null && notes.isNotEmpty) ...[
                Text(
                  notes,
                  style: const TextStyle(color: ThemeColors.textGrey),
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: products.isEmpty
                    ? Center(
                        child: Text(
                          loc.t('products.empty.description'),
                          style: const TextStyle(color: ThemeColors.textGrey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = products[index];
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
                                color: ThemeColors.bgCard,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: ThemeColors.bg3,
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
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
