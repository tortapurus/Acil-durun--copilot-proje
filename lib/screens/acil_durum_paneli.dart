import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class AcilDurumPaneli extends StatelessWidget {
  const AcilDurumPaneli({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        centerTitle: true,
        title: const Text(
          'Acil Durum',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications, color: Colors.white),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Acil Durum Çantası Bölümü
            _buildSection(
              context,
              title: 'Acil Durum Çantası',
              items: [
                _buildStatusCard(
                  context,
                  status: 'Yakında Sona Erecek',
                  count: productProvider.yakindaBitecekUrunler.length,
                  description: '${productProvider.yakindaBitecekUrunler.length} ürünün son kullanma tarihi yaklaşıyor',
                  borderColor: const Color(0xFFF59E0B), // yellow-500
                  imagePath: null,
                ),
                _buildStatusCard(
                  context,
                  status: 'Eksik',
                  count: 2,
                  description: 'Su ve İlk yardım çantası eklenmeyi bekliyor',
                  borderColor: const Color(0xFFEF4444), // red-500
                  imagePath: null,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Depo Paneli Bölümü
            _buildSection(
              context,
              title: 'Depo Paneli',
              items: [
                _buildStatusCard(
                  context,
                  status: 'Yakında Sona Erecek',
                  count: productProvider.yakindaBitecekUrunler.where((p) => p.konum?.contains('Depo') ?? false).length,
                  description: 'Depodaki ürünler kontrol edilmeli',
                  borderColor: const Color(0xFFF59E0B),
                  imagePath: null,
                ),
                _buildStatusCard(
                  context,
                  status: 'Güvenli',
                  count: productProvider.guvenliUrunler.where((p) => p.konum?.contains('Depo') ?? false).length,
                  description: 'Tüm ürünler stokta',
                  borderColor: const Color(0xFFA2E4B8), // pastel-green
                  imagePath: null,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String status,
    required int count,
    required String description,
    required Color borderColor,
    String? imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: borderColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: borderColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$count Ürün',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (imagePath != null)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: Colors.white,
                  size: 30,
                ),
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
          _buildNavItem(Icons.home, 'Ana Sayfa', true), // Aktif
          _buildNavItem(Icons.work_outline, 'Çantalar', false),
          _buildNavItem(Icons.inventory_2, 'Depo', false),
          _buildNavItem(Icons.info, 'Bilgi Merkezi', false),
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
