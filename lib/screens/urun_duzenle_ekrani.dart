import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../services/notification_service.dart';

class UrunDuzenleEkrani extends StatefulWidget {
  final Product product;

  const UrunDuzenleEkrani({super.key, required this.product});

  @override
  State<UrunDuzenleEkrani> createState() => _UrunDuzenleEkraniState();
}

class _UrunDuzenleEkraniState extends State<UrunDuzenleEkrani> {
  late TextEditingController _adController;
  late TextEditingController _notlarController;
  late TextEditingController _konumController;
  
  String? _secilenKategori;
  DateTime? _sonKullanmaTarihi;
  DateTime? _hatirlatmaTarihi;
  String? _resimYolu;

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController(text: widget.product.ad);
    _notlarController = TextEditingController(text: widget.product.notlar ?? '');
    _konumController = TextEditingController(text: widget.product.konum ?? '');
    _secilenKategori = widget.product.kategori;
    _sonKullanmaTarihi = widget.product.sonKullanmaTarihi;
    _hatirlatmaTarihi = widget.product.hatirlatmaTarihi;
    _resimYolu = widget.product.resimYolu;
  }

  @override
  void dispose() {
    _adController.dispose();
    _notlarController.dispose();
    _konumController.dispose();
    super.dispose();
  }

  Future<void> _resimSec() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _resimYolu = image.path;
      });
    }
  }

  Future<void> _tarihSec(bool sonKullanma) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: sonKullanma ? _sonKullanmaTarihi! : _hatirlatmaTarihi!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (sonKullanma) {
          _sonKullanmaTarihi = picked;
        } else {
          _hatirlatmaTarihi = picked;
        }
      });
    }
  }

  void _guncelle() async {
    if (_adController.text.isNotEmpty && 
        _secilenKategori != null && 
        _sonKullanmaTarihi != null &&
        _hatirlatmaTarihi != null) {
      
      final updatedProduct = Product(
        id: widget.product.id,
        ad: _adController.text,
        kategori: _secilenKategori!,
        sonKullanmaTarihi: _sonKullanmaTarihi!,
        hatirlatmaTarihi: _hatirlatmaTarihi!,
        notlar: _notlarController.text.isEmpty ? null : _notlarController.text,
        konum: _konumController.text.isEmpty ? null : _konumController.text,
        resimYolu: _resimYolu,
        kontrolEdildi: widget.product.kontrolEdildi,
      );

      await context.read<ProductProvider>().updateProduct(updatedProduct);
      await NotificationService().cancelProductReminder(widget.product.id);
      await NotificationService().scheduleProductReminder(updatedProduct);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün güncellendi!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF111714),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111714),
        title: const Text('Ürünü Düzenle', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _adController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Ürün Adı',
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _secilenKategori,
            dropdownColor: const Color(0xFF1F1F1F),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Kategori',
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
            ),
            items: categoryProvider.categories
                .map((cat) => DropdownMenuItem<String>(
                      value: cat.id,
                      child: Text(cat.ad),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _secilenKategori = value),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: const Color(0xFF1F1F1F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Son Kullanma Tarihi', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              '${_sonKullanmaTarihi!.day}/${_sonKullanmaTarihi!.month}/${_sonKullanmaTarihi!.year}',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.calendar_today, color: Colors.white),
            onTap: () => _tarihSec(true),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: const Color(0xFF1F1F1F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Hatırlatma Tarihi', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              '${_hatirlatmaTarihi!.day}/${_hatirlatmaTarihi!.month}/${_hatirlatmaTarihi!.year}',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.notifications, color: Colors.white),
            onTap: () => _tarihSec(false),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notlarController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notlar',
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _konumController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Konum',
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _resimSec,
            icon: const Icon(Icons.image),
            label: Text(_resimYolu != null ? 'Resim değiştir' : 'Resim Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF111714),
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _guncelle,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF38E07B),
            foregroundColor: const Color(0xFF111714),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text('Güncelle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}
