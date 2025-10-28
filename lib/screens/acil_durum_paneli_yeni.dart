import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';
import '../widgets/app_bottom_navigation.dart';

class AcilDurumPaneli extends StatelessWidget {
  const AcilDurumPaneli({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.bg1,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: ThemeColors.textWhite),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Depo Paneli',
                      style: TextStyle(
                        color: ThemeColors.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Bags Section
              const Text(
                'Acil Durum Çantaları',
                style: TextStyle(
                  color: ThemeColors.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _PanelCard(
                title: 'Ev Acil Durum Çantası',
                itemCount: '12 ürün',
                status: 'Güncel',
                statusColor: ThemeColors.pastelGreen,
                onTap: () {},
              ),
              
              const SizedBox(height: 12),
              
              _PanelCard(
                title: 'Araba Çantası',
                itemCount: '8 ürün',
                status: 'Eksik Ürünler',
                statusColor: ThemeColors.pastelYellow,
                onTap: () {},
              ),
              
              const SizedBox(height: 32),
              
              // Storage Section
              const Text(
                'Depo Alanları',
                style: TextStyle(
                  color: ThemeColors.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _PanelCard(
                title: 'Ana Depo',
                itemCount: '24 ürün',
                status: 'Son Kullanma Tarihi Yaklaşıyor',
                statusColor: ThemeColors.pastelYellow,
                onTap: () {},
              ),
              
              const SizedBox(height: 12),
              
              _PanelCard(
                title: 'Yedek Depo',
                itemCount: '15 ürün',
                status: 'Güncel',
                statusColor: ThemeColors.pastelGreen,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(current: AppNavItem.depot),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({
    required this.title,
    required this.itemCount,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  final String title;
  final String itemCount;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: ThemeColors.bgCard,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: ThemeColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: ThemeColors.textGrey,
                  size: 16,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              itemCount,
              style: const TextStyle(
                color: ThemeColors.textGrey,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: statusColor.withValues(alpha: 0.2),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}