import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../services/localization_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';

class UygulamaBilgileriEkrani extends StatefulWidget {
  const UygulamaBilgileriEkrani({super.key});

  @override
  State<UygulamaBilgileriEkrani> createState() => _UygulamaBilgileriEkraniState();
}

class _UygulamaBilgileriEkraniState extends State<UygulamaBilgileriEkrani> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocalizationService, SettingsService>(
      builder: (context, loc, settings, child) {
        final colors = AppThemeColors.read(context);

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
              loc.t('appInfo.title'),
              style: const TextStyle(
                color: ThemeColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: FutureBuilder<PackageInfo>(
              future: _packageInfoFuture,
              builder: (context, snapshot) {
                final info = snapshot.data;
                final version = info?.version ?? '—';
                final buildNumber = info?.buildNumber ?? '—';
                final packageName = info?.packageName ?? '—';

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.t('appInfo.description'),
                        style: const TextStyle(
                          color: ThemeColors.textGrey,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _InfoCard(
                        colors: colors,
                        useDividers: true,
                        children: [
                          _buildInfoRow(loc.t('appInfo.version'), version, colors),
                          _buildInfoRow(loc.t('appInfo.build'), buildNumber, colors),
                          _buildInfoRow(loc.t('appInfo.package'), packageName, colors),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _InfoCard(
                        colors: colors,
                        useDividers: false,
                        children: [
                          _buildBulletText(loc.t('appInfo.dataStorage')),
                          const SizedBox(height: 12),
                          _buildBulletText(loc.t('appInfo.support')),
                        ],
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ThemeColors.pastelGreen.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: ThemeColors.textGrey,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(
            Icons.check_circle_outline,
            color: ThemeColors.pastelGreen,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: ThemeColors.textWhite,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.colors,
    required this.children,
    required this.useDividers,
  });

  final AppThemeColors colors;
  final List<Widget> children;
  final bool useDividers;

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      content.add(children[i]);
      if (useDividers && i < children.length - 1) {
        content.add(Divider(
          color: colors.divider,
          height: 1,
          thickness: 0.6,
          indent: 16,
          endIndent: 16,
        ));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      ),
    );
  }
}
