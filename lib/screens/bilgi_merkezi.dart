import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/app_bottom_navigation.dart';

class BilgiMerkezi extends StatelessWidget {
  const BilgiMerkezi({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, loc, child) => Scaffold(
        backgroundColor: ThemeColors.bg1,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.t('nav.info'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ThemeColors.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Upload button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.pastelGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.t('info.uploadSnack')),
                          backgroundColor: ThemeColors.pastelGreen,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          color: ThemeColors.textBlack,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.t('info.uploadButton'),
                          style: const TextStyle(
                            color: ThemeColors.textBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Files section
                Text(
                  loc.t('info.filesTitle'),
                  style: const TextStyle(
                    color: ThemeColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Sample files
                _FileCard(
                  fileName: 'Acil_Hazirlik_Rehberi.pdf',
                  fileMeta: '2.4 MB • 15.10.2025',
                  icon: Icons.description_outlined,
                  chipColor: ThemeColors.pastelBlue,
                  onDownload: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.t('info.file.downloadSnack')),
                        backgroundColor: ThemeColors.pastelBlue,
                      ),
                    );
                  },
                  onDelete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.t('info.file.deleteSnack')),
                        backgroundColor: ThemeColors.pastelRed,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                _FileCard(
                  fileName: 'Canta_Icerigi.jpg',
                  fileMeta: '1.8 MB • 12.10.2025',  
                  icon: Icons.image_outlined,
                  chipColor: ThemeColors.pastelPurple,
                  onDownload: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.t('info.file.downloadSnack')),
                        backgroundColor: ThemeColors.pastelBlue,  
                      ),
                    );
                  },
                  onDelete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.t('info.file.deleteSnack')),
                        backgroundColor: ThemeColors.pastelRed,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                _FileCard(
                  fileName: 'İlk_Yardim_Rehberi.pdf',
                  fileMeta: '3.1 MB • 10.10.2025',
                  icon: Icons.local_hospital_outlined,
                  chipColor: ThemeColors.pastelRed,
                  onDownload: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.t('info.file.downloadSnack')),
                        backgroundColor: ThemeColors.pastelBlue,
                      ),
                    );
                  },
                  onDelete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.t('info.file.deleteSnack')),
                        backgroundColor: ThemeColors.pastelRed,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 80), // Bottom padding for navigation
              ],
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(
          current: AppNavItem.info,
        ),
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  final String fileName;
  final String fileMeta;
  final IconData icon;
  final Color chipColor;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _FileCard({
    required this.fileName,
    required this.fileMeta,
    required this.icon,
    required this.chipColor,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: chipColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: ThemeColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fileMeta,
                  style: TextStyle(
                    color: ThemeColors.textGrey.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color: ThemeColors.textGrey,
            ),
            color: ThemeColors.bgCard,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'download',
                child: Consumer<LocalizationService>(
                  builder: (context, loc, child) => Row(
                    children: [
                      const Icon(Icons.download, color: ThemeColors.textWhite, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        loc.t('info.file.download'),
                        style: const TextStyle(color: ThemeColors.textWhite),
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Consumer<LocalizationService>(
                  builder: (context, loc, child) => Row(
                    children: [
                      const Icon(Icons.delete, color: ThemeColors.pastelRed, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        loc.t('info.file.delete'),
                        style: const TextStyle(color: ThemeColors.pastelRed),
                      ),  
                    ],
                  ),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'download') {
                onDownload();
              } else if (value == 'delete') {
                onDelete();
              }
            },
          ),
        ],
      ),
    );
  }
}