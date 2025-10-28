import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../services/data_service.dart';
import '../services/localization_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';

class YonetimPaneli extends StatefulWidget {
  const YonetimPaneli({super.key});

  @override
  State<YonetimPaneli> createState() => _YonetimPaneliState();
}

class _YonetimPaneliState extends State<YonetimPaneli> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LocalizationService, DataService, SettingsService>(
      builder: (context, loc, data, settings, child) {
        final colors = AppThemeColors.read(context);
        final fixedCategories = Category.fixedCategories;
        final customCategories = data.allCategories
            .where((category) => category.isCustom)
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        return Scaffold(
          backgroundColor: colors.bg1,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: ThemeColors.textWhite),
              onPressed: () => Navigator.pop(context),
              tooltip: loc.t('common.back'),
            ),
            title: Text(
              loc.t('management.title'),
              style: const TextStyle(
                color: ThemeColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('management.subtitle'),
                    style: const TextStyle(
                      color: ThemeColors.textGrey,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: loc.t('management.fixed.title'),
                    subtitle: loc.t('management.fixed.count', {
                      'count': fixedCategories.length.toString(),
                    }),
                    description: loc.t('management.fixed.description'),
                    colors: colors,
                    children: fixedCategories.map((category) {
                      final productCount = _productCountForCategory(data, category.id);
                      return _CategoryTile(
                        title: data.resolveCategoryLabel(category.id, loc),
                        subtitle: loc.t('management.stats.products', {
                          'count': productCount.toString(),
                        }),
                        leading: Icons.lock_outline,
                        leadingColor: ThemeColors.pastelBlue,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: loc.t('management.custom.title'),
                    subtitle: loc.t('management.custom.subtitle'),
                    description: customCategories.isEmpty
                        ? loc.t('management.custom.empty')
                        : null,
                    trailing: TextButton.icon(
                      onPressed: () => _openAddCategoryDialog(context, loc, data),
                      icon: const Icon(Icons.add, color: ThemeColors.pastelGreen, size: 20),
                      label: Text(
                        loc.t('management.add.button'),
                        style: const TextStyle(color: ThemeColors.pastelGreen),
                      ),
                    ),
                    colors: colors,
                    children: customCategories.map((category) {
                      final productCount = _productCountForCategory(data, category.id);
                      return _CategoryTile(
                        title: data.resolveCategoryLabel(category.id, loc),
                        subtitle: loc.t('management.stats.products', {
                          'count': productCount.toString(),
                        }),
                        leading: Icons.label_outline,
                        leadingColor: ThemeColors.pastelGreen,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: ThemeColors.pastelRed),
                          onPressed: () => _confirmDelete(context, loc, data, category),
                          tooltip: loc.t('management.delete.action'),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _productCountForCategory(DataService data, String categoryId) {
    return data.products.where((product) => product.categoryId == categoryId).length;
  }

  Future<void> _openAddCategoryDialog(
    BuildContext context,
    LocalizationService loc,
    DataService data,
  ) async {
    _controller.clear();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppThemeColors.read(dialogContext).bg2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            loc.t('management.add.dialog.title'),
            style: const TextStyle(color: ThemeColors.textWhite),
          ),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: ThemeColors.textWhite),
              decoration: InputDecoration(
                hintText: loc.t('management.add.dialog.hint'),
                hintStyle: const TextStyle(color: ThemeColors.textGrey),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.length < 2) {
                  return loc.t('management.add.dialog.error.length');
                }
                final exists = data.allCategories.any(
                  (category) => category.name.toLowerCase() == text.toLowerCase(),
                );
                if (exists) {
                  return loc.t('management.add.dialog.error.duplicate');
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(loc.t('management.delete.cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                final name = _controller.text.trim();
                final category = Category(
                  id: name.toLowerCase().replaceAll(RegExp(r'\s+'), '_'),
                  name: name,
                  isCustom: true,
                );
                data.addCustomCategory(category);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.t('management.add.success', {'name': name}))),
                );
              },
              child: Text(loc.t('management.add.dialog.action')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LocalizationService loc,
    DataService data,
    Category category,
  ) async {
    final colors = AppThemeColors.read(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.bg2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            loc.t('management.delete.action'),
            style: const TextStyle(color: ThemeColors.textWhite),
          ),
          content: Text(
            loc.t('management.delete.confirm', {'name': category.name}),
            style: const TextStyle(color: ThemeColors.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(loc.t('management.delete.cancel')),
            ),
            TextButton(
              onPressed: () {
                data.deleteCustomCategory(category.id);
                Navigator.pop(dialogContext);
              },
              child: Text(
                loc.t('management.delete.action'),
                style: const TextStyle(color: ThemeColors.pastelRed),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.colors,
    this.description,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String? description;
  final Widget? trailing;
  final List<Widget> children;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.bgCardDark.withValues(alpha: 0.4)),
      ),
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
                      title,
                      style: const TextStyle(
                        color: ThemeColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: ThemeColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description!,
              style: const TextStyle(
                color: ThemeColors.textGrey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          if (children.isNotEmpty) ...[
            const SizedBox(height: 16),
            Column(children: children),
          ],
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.leadingColor,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData leading;
  final Color leadingColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: leadingColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: leadingColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(leading, color: leadingColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ThemeColors.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: ThemeColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
