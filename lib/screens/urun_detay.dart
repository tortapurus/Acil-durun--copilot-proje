import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../services/settings_service.dart';
import '../theme/theme_colors.dart';
import '../theme/app_theme.dart';

class UrunDetay extends StatelessWidget {
  const UrunDetay({super.key, this.productId});

  final String? productId;

  @override
  Widget build(BuildContext context) {
    return Consumer3<LocalizationService, DataService, SettingsService>(
      builder: (context, loc, data, settings, child) {
        final Product? product =
            productId != null ? data.getProductById(productId!) : null;
        final colors = AppThemeColors.read(context);

        if (product == null) {
          return Scaffold(
            backgroundColor: colors.bg2,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(title: loc.t('productDetail.title')),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          loc.t('productDetail.notFound'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: ThemeColors.textGrey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final String expirySubtitle = product.isExpired
            ? loc.t('expired')
            : '(${loc.t('productDetail.expiry.remaining', {
                'days': product.daysRemaining.toString(),
              })})';
        final String reminderDate = _formatDate(product.reminderDate);
        final String expiryDate = _formatDate(product.expiryDate);
        final String lastUpdated = _formatDate(product.createdAt);
        final String? storageLabel = _storageLabel(loc, data, product);
    final String categoryLabel =
      data.resolveCategoryLabel(product.categoryId, loc);
        final String? locationNote = product.location?.trim().isEmpty ?? true
            ? null
            : product.location!.trim();
        final String locationText = _composeSectionText(
          storageLabel,
          locationNote,
          loc.t('productDetail.location.empty'),
        );
        final String notesText = product.notes?.trim().isEmpty ?? true
            ? loc.t('productDetail.notes.empty')
            : product.notes!.trim();

        return Scaffold(
          backgroundColor: colors.bg2,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(title: loc.t('productDetail.title')),
                  const SizedBox(height: 16),
                  _ProductHero(
                    imagePath: settings.showProductImages ? product.imagePath : null,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: ThemeColors.textWhite,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${loc.t('products.category')}: $categoryLabel',
                          style: const TextStyle(
                            color: ThemeColors.textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _DateCard(
                            title: loc.t('productDetail.expiry.label'),
                            date: expiryDate,
                            subtitle: expirySubtitle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DateCard(
                            title: loc.t('productDetail.reminder.label'),
                            date: reminderDate,
                            subtitle: '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _Section(
                    icon: Icons.location_on_outlined,
                    title: loc.t('productDetail.location.label'),
                    content: locationText,
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    icon: Icons.sticky_note_2_outlined,
                    title: loc.t('productDetail.notes.label'),
                    content: notesText,
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    icon: Icons.access_time,
                    title: loc.t('productDetail.lastUpdated'),
                    content: lastUpdated,
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A3D32),
                              foregroundColor: ThemeColors.textWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/yeni-urun',
                                arguments: {'productId': product.id},
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            label: Text(
                              loc.t('edit'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColors.pastelGreen,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              _showDeleteDialog(
                                context,
                                loc,
                                onConfirm: () {
                                  data.deleteProduct(product.id);
                                  Navigator.pop(context);
                                },
                              );
                            },
                            icon: const Icon(Icons.delete_outline, size: 20),
                            label: Text(
                              loc.t('delete'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day.$month.$year';
  }

  static String _composeSectionText(
    String? primary,
    String? secondary,
    String fallback,
  ) {
    final List<String> parts = [];
    if (primary != null && primary.isNotEmpty) {
      parts.add(primary);
    }
    if (secondary != null && secondary.isNotEmpty) {
      parts.add(secondary);
    }
    if (parts.isEmpty) {
      return fallback;
    }
    return parts.join('\n');
  }

  static String? _storageLabel(
    LocalizationService loc,
    DataService data,
    Product product,
  ) {
    if (product.storageId == null || product.storageType == null) {
      return null;
    }

    switch (product.storageType!) {
      case StorageLocationType.bag:
        final bag = data.getBagById(product.storageId!);
        if (bag == null) return null;
        return loc.t('newProduct.storage.selected', {
          'type': loc.t('newProduct.storage.type.bag'),
          'name': bag.name,
        });
      case StorageLocationType.depot:
        final depot = data.getDepotById(product.storageId!);
        if (depot == null) return null;
        return loc.t('newProduct.storage.selected', {
          'type': loc.t('newProduct.storage.type.depot'),
          'name': depot.name,
        });
    }
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    Widget? image;
    if (imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('http')) {
        image = Image.network(
          imagePath!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
        );
      } else {
        final file = File(imagePath!);
        if (file.existsSync()) {
          image = Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
          );
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: image ?? const _ImagePlaceholder(),
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_outlined,
        color: Colors.white,
        size: 72,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: ThemeColors.textWhite,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: ThemeColors.pastelGreen,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: ThemeColors.textWhite,
                      fontSize: 14,
                      height: 1.4,
                    ),
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

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.title,
    required this.date,
    required this.subtitle,
  });

  final String title;
  final String date;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ThemeColors.textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: ThemeColors.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

void _showDeleteDialog(
  BuildContext context,
  LocalizationService loc, {
  required VoidCallback onConfirm,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: ThemeColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        loc.t('productDetail.delete.title'),
        style: const TextStyle(
          color: ThemeColors.textWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        loc.t('productDetail.delete.message'),
        style: const TextStyle(color: ThemeColors.textGrey),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            loc.t('common.cancel'),
            style: const TextStyle(color: ThemeColors.textWhite),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onConfirm();
          },
          child: Text(
            loc.t('delete'),
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}


