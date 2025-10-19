import 'package:flutter/material.dart';

class BilgiMerkezi extends StatelessWidget {
  const BilgiMerkezi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'Bilgi Merkezi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Yeni Dosya Yükle Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dosya yükleme yakında eklenecek')),
                  );
                },
                icon: const Icon(Icons.upload_file, color: Colors.black),
                label: const Text(
                  'Yeni Dosya Yükle',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA2E4B8), // pastel-green
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Yüklenmiş Dosyalar Başlığı
            const Text(
              'Yüklenmiş Dosyalar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Örnek PDF Dosyası
            _buildFileCard(
              icon: Icons.description,
              fileName: 'Acil_Durum_Plani.pdf',
              fileSize: '2.4 MB',
              uploadDate: '15 Mart 2025',
              backgroundColor: const Color(0xFFA2C4E4), // pastel-blue
            ),

            // Örnek JPG Dosyası
            _buildFileCard(
              icon: Icons.image,
              fileName: 'Canta_Icerigi.jpg',
              fileSize: '1.8 MB',
              uploadDate: '12 Mart 2025',
              backgroundColor: const Color(0xFFC4A2E4), // pastel-purple
            ),

            // Örnek ZIP Dosyası
            _buildFileCard(
              icon: Icons.folder_zip,
              fileName: 'Evraklar_Yedek.zip',
              fileSize: '5.2 MB',
              uploadDate: '10 Mart 2025',
              backgroundColor: const Color(0xFF888888), // gri
            ),

            // Örnek PDF Dosyası 2
            _buildFileCard(
              icon: Icons.description,
              fileName: 'Ilk_Yardim_Rehberi.pdf',
              fileSize: '3.1 MB',
              uploadDate: '08 Mart 2025',
              backgroundColor: const Color(0xFFA2C4E4),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildFileCard({
    required IconData icon,
    required String fileName,
    required String fileSize,
    required String uploadDate,
    required Color backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          fileName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '$fileSize • $uploadDate',
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 14,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF2F2F2F),
          onSelected: (value) {
            if (value == 'download') {
              // İndirme işlemi
            } else if (value == 'share') {
              // Paylaşma işlemi
            } else if (value == 'delete') {
              // Silme işlemi
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'download',
              child: Text('İndir', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Text('Paylaş', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF1F1F1F),
        border: Border(top: BorderSide(color: Color(0xFF333333))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Ana Sayfa', false),
          _buildNavItem(Icons.work_outline, 'Çantalar', false),
          _buildNavItem(Icons.inventory_2, 'Depo', false),
          _buildNavItem(Icons.info, 'Bilgi Merkezi', true), // Aktif - yeşil
          _buildNavItem(Icons.grid_view, 'Kategoriler', false),
          _buildNavItem(Icons.settings, 'Ayarlar', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? const Color(0xFFA2E4B8) : Colors.grey,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFFA2E4B8) : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
