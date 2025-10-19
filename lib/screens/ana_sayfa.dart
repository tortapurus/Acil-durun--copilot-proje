import 'package:acil_durum_takip/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acil_durum_takip/screens/urun_ekle_ekrani.dart';
import 'package:acil_durum_takip/screens/urun_listesi_ekrani.dart';
import 'package:acil_durum_takip/screens/acil_durum_paneli.dart';
import 'package:acil_durum_takip/screens/bilgi_merkezi.dart';
import 'package:acil_durum_takip/screens/yeni_canta_olustur.dart';
import '../providers/product_provider.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'Ana Sayfa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔴 Kritik Uyarılar
            if (productProvider.suresiDolmusUrunler.isNotEmpty)
              _buildWarningCard(
                context,
                title: 'Kritik Uyarılar',
                subtitle: '${productProvider.suresiDolmusUrunler.length} ürünün son kullanma tarihi geçti.${productProvider.suresiDolmusUrunler.length > 1 ? '\nLütfen kontrol ediniz.' : ''}',
                gradient: const LinearGradient(
                  colors: [Color(0xFFF4A8A8), Color(0xFFEF4444)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                icon: Icons.warning,
                iconColor: Colors.white,
                textColor: Colors.white,
              ),

            // 🟽 Yaklaşan Son Kullanma Tarihleri
            if (productProvider.yakindaBitecekUrunler.isNotEmpty)
              _buildWarningCard(
                context,
                title: 'Yaklaşan Son Kullanma Tarihleri',
                subtitle: '${productProvider.yakindaBitecekUrunler.length} ürünün son kullanma tarihi 7 gün içinde dolacak.',
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8E4A0), Color(0xFFFACC15)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                icon: Icons.hourglass_top,
                iconColor: const Color(0xFF333333),
                textColor: const Color(0xFF333333),
              ),

            // 📊 Genel Bakış
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Genel Bakış',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard('${productProvider.products.length}', 'Toplam Ürün'),
                      const SizedBox(width: 16),
                      _buildStatCard('4', 'Acil Durum Çantası'),
                    ],
                  ),
                ],
              ),
            ),

            // ⚡ Hızlı Eylemler
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hızlı Eylemler',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionCard(context, Icons.add, 'Ürün Ekle', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const YeniUrunEkleEkrani()));
                        }),
                        _buildActionCard(context, Icons.qr_code_scanner, 'Barkod Tara', () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Barkod tarayıcı yakında eklenecek')),
                          );
                        }),
                        _buildActionCard(context, Icons.inventory_2, 'Stok Yönetimi', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const UrunListesiEkrani()));
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildWarningCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Gradient gradient,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor,
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

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return Card(
      color: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 100,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 28, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
          _buildNavItem(Icons.work_outline, 'Çantalar', 0),
          _buildNavItem(Icons.inventory_2, 'Depo', 1),
          _buildNavItem(Icons.list_alt, 'Ürünler', 2),
          _buildNavItem(Icons.grid_view, 'Kategoriler', 3),
          _buildNavItem(Icons.settings, 'Ayarlar', 4),
          _buildNavItem(Icons.info, 'Bilgi Merkezi', 5),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    // Bilgi Merkezi (index 5) her zaman yeşil
    final isActive = index == 5;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 0) {
            // Çantalar - Yeni Çanta Oluştur ekranına git
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const YeniCantaOlustur()),
            );
          } else if (index == 1) {
            // Depo - Acil Durum Paneli'ne git
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AcilDurumPaneli()),
            );
          } else if (index == 2) {
            // Ürünler
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UrunListesiEkrani()),
            );
          } else if (index == 3) {
            // Kategoriler
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kategoriler sayfası yakında eklenecek')),
            );
          } else if (index == 4) {
            // Ayarlar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ayarlar sayfası yakında eklenecek')),
            );
          } else if (index == 5) {
            // Bilgi Merkezi
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BilgiMerkezi()),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isActive ? const Color(0xFFA2E4B8) : Colors.grey),
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
      ),
    );
  }
}