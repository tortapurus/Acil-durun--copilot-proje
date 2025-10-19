import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../services/notification_service.dart';
import 'urun_duzenle_ekrani.dart';

class UrunDetayEkrani extends StatelessWidget {
  final String productId;

  const UrunDetayEkrani({super.key, required this.productId});

  Color _getDurumRengi(ProductStatus durum) {
    switch (durum) {
      case ProductStatus.guvenli:
        return const Color(0xFFA2E4B8);
      case ProductStatus.yakindaBitecek:
        return const Color(0xFFF8E4A0);
      case ProductStatus.suresiDolmus:
        return const Color(0xFFF4A8A8);
    }
  }

  String _getDurumMetni(ProductStatus durum) {
    switch (durum) {
      case ProductStatus.guvenli:
        return 'Güvenli';
      case ProductStatus.yakindaBitecek:
        return 'Yakında Bitecek';
      case ProductStatus.suresiDolmus:
        return 'Süresi Dolmuş';
    }
  }

  void _silOnayi(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Ürünü Sil', style: TextStyle(color: Colors.white)),
        content: Text(
          '${product.ad} ürününü silmek istediğinize emin misiniz?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await context.read<ProductProvider>().deleteProduct(product.id);
              await NotificationService().cancelProductReminder(product.id);
              
              if (context.mounted) {
                Navigator.pop(context); // Dialog'u kapat
                Navigator.pop(context); // Detay ekranını kapat
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ürün silindi')),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final product = productProvider.getProductById(productId);

    if (product == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          title: const Text('Ürün Bulunamadı'),
        ),
        body: const Center(
          child: Text(
            'Ürün bulunamadı',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Ürün Detayı', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UrunDuzenleEkrani(product: product),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _silOnayi(context, product),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Durum kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getDurumRengi(product.durum),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    _getDurumMetni(product.durum),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.kalanGun} gün kaldı',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Ürün adı
            _buildInfoCard('Ürün Adı', product.ad, Icons.inventory),
            
            // Kategori
            _buildInfoCard('Kategori', product.kategori, Icons.category),
            
            // Son kullanma tarihi
            _buildInfoCard(
              'Son Kullanma Tarihi',
              '${product.sonKullanmaTarihi.day}/${product.sonKullanmaTarihi.month}/${product.sonKullanmaTarihi.year}',
              Icons.calendar_today,
            ),
            
            // Hatırlatma tarihi
            _buildInfoCard(
              'Hatırlatma Tarihi',
              '${product.hatirlatmaTarihi.day}/${product.hatirlatmaTarihi.month}/${product.hatirlatmaTarihi.year}',
              Icons.notifications,
            ),
            
            // Konum
            if (product.konum != null)
              _buildInfoCard('Konum', product.konum!, Icons.location_on),
            
            // Notlar
            if (product.notlar != null)
              _buildInfoCard('Notlar', product.notlar!, Icons.note),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String baslik, String icerik, IconData ikon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(ikon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  icerik,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
