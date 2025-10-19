import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'urun_detay_ekrani.dart';
import 'urun_ekle_ekrani.dart';

class UrunListesiEkrani extends StatefulWidget {
  const UrunListesiEkrani({super.key});

  @override
  State<UrunListesiEkrani> createState() => _UrunListesiEkraniState();
}

class _UrunListesiEkraniState extends State<UrunListesiEkrani> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Tümü';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getDurumMetni(ProductStatus durum) {
    switch (durum) {
      case ProductStatus.guvenli:
        return 'Güvenli';
      case ProductStatus.yakindaBitecek:
        return 'Yakında Bitecek';
      case ProductStatus.suresiDolmus:
        return 'Süresi doldu'; // Döküman speci - küçük harfle
    }
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products.where((p) {
      final matchesSearch = p.ad.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    // Filtreleme
    if (_selectedFilter == 'Kalan Gün') {
      filtered.sort((a, b) => a.kalanGun.compareTo(b.kalanGun));
    } else if (_selectedFilter == 'Ad') {
      filtered.sort((a, b) => a.ad.compareTo(b.ad));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final filteredProducts = _filterProducts(productProvider.products);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ürünler',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ürün ara...',
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1F1F1F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA2E4B8), // pastel-green
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filtre Butonları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tümü'),
                  _buildFilterChip('Kategori'),
                  _buildFilterChip('Kalan Gün'),
                  _buildFilterChip('Ad'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Ürün Listesi
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'Ürün bulunamadı',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFFA2E4B8), // pastel-green
        backgroundColor: const Color(0xFF1F1F1F),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        side: BorderSide(
          color: isSelected ? const Color(0xFFA2E4B8) : const Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UrunDetayEkrani(productId: product.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Resim - sol üstte, yuvarlak
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F2F2F),
                  shape: BoxShape.circle,
                ),
                child: product.resimYolu != null
                    ? ClipOval(
                        child: Icon(
                          Icons.inventory_2,
                          color: Colors.white,
                          size: 30,
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),

              // Sağda: Ürün bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ürün adı (beyaz, bold)
                    Text(
                      product.ad,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Kalan gün (gri)
                    Text(
                      product.durum == ProductStatus.suresiDolmus
                          ? 'Süresi doldu'
                          : '${product.kalanGun} gün kaldı',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Stok (gri) - örnek veri
                    Text(
                      'Kategori: ${product.kategori}',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
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
          _buildNavItem(Icons.list_alt, 'Ürünler', true), // Aktif - yeşil
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
