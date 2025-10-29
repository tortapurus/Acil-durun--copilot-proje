import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../theme/theme_colors.dart';

class CantaDetay extends StatelessWidget {
  const CantaDetay({super.key, required this.bagId});

  final String? bagId;

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();
    final data = context.watch<DataService>();

    final bag = bagId == null ? null : data.getBagById(bagId!);
    final List<Product> products = bagId == null ? [] : data.getProductsInBag(bagId!);
    final String? notes = bag?.notes;

    return Scaffold(
      backgroundColor: ThemeColors.bg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(bag?.name ?? loc.t('bags.title')),
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
                                  // Product image (left)
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.transparent,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _buildProductImage(product),
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

  Widget _buildProductImage(Product product) {
    if (product.imagePath != null && product.imagePath!.isNotEmpty) {
      final String path = product.imagePath!;
      try {
        if (path.startsWith('http')) {
          return Image.network(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_outlined, color: ThemeColors.textGrey),
          );
        } else {
          final file = File(path);
          if (file.existsSync()) {
            return Image.file(file, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_outlined, color: ThemeColors.textGrey));
          }
        }
      } catch (_) {
        // ignore and fallthrough to placeholder
      }
    }

    return const Icon(Icons.inventory_2_outlined, color: ThemeColors.textGrey);
  }
}
