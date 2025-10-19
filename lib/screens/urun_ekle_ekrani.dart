import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../services/notification_service.dart';

class YeniUrunEkleEkrani extends StatefulWidget {
  const YeniUrunEkleEkrani({super.key});

  @override
  State<YeniUrunEkleEkrani> createState() => _YeniUrunEkleEkraniState();
}

class _YeniUrunEkleEkraniState extends State<YeniUrunEkleEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _notlarController = TextEditingController();
  final _konumController = TextEditingController();
  
  String? _secilenKategori;
  DateTime? _sonKullanmaTarihi;
  DateTime? _hatirlatmaTarihi;
  String? _resimYolu;
  int _hatirlatmaGunSayisi = 3;

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
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (sonKullanma) {
          _sonKullanmaTarihi = picked;
          _hatirlatmaTarihi = picked.subtract(Duration(days: _hatirlatmaGunSayisi));
        } else {
          _hatirlatmaTarihi = picked;
        }
      });
    }
  }

  void _kaydet() async {
    if (_formKey.currentState!.validate() && 
        _secilenKategori != null && 
        _sonKullanmaTarihi != null) {
      final product = Product(
        id: const Uuid().v4(),
        ad: _adController.text,
        kategori: _secilenKategori!,
        sonKullanmaTarihi: _sonKullanmaTarihi!,
        hatirlatmaTarihi: _hatirlatmaTarihi ?? _sonKullanmaTarihi!.subtract(const Duration(days: 3)),
        notlar: _notlarController.text.isEmpty ? null : _notlarController.text,
        konum: _konumController.text.isEmpty ? null : _konumController.text,
        resimYolu: _resimYolu,
      );

      await context.read<ProductProvider>().addProduct(product);
      await NotificationService().scheduleProductReminder(product);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla eklendi!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm gerekli alanları doldurun!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF111714),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111714),
        title: const Text('Yeni Ürün Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _adController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Ürün Adı',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Gerekli alan' : null,
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
              validator: (value) => value == null ? 'Kategori seçiniz' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              tileColor: const Color(0xFF1F1F1F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: const Text('Son Kullanma Tarihi', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                _sonKullanmaTarihi != null
                    ? '${_sonKullanmaTarihi!.day}/${_sonKullanmaTarihi!.month}/${_sonKullanmaTarihi!.year}'
                    : 'Tarih seçiniz',
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
                _hatirlatmaTarihi != null
                    ? '${_hatirlatmaTarihi!.day}/${_hatirlatmaTarihi!.month}/${_hatirlatmaTarihi!.year}'
                    : 'Otomatik: ${_hatirlatmaGunSayisi} gün önce',
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(Icons.notifications, color: Colors.white),
              onTap: () => _tarihSec(false),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notlarController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notlar (isteğe bağlı)',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _konumController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Konum (isteğe bağlı)',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Örn: Çanta 1, Mutfak Dolabı',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resimSec,
              icon: const Icon(Icons.image),
              label: Text(_resimYolu != null ? 'Resim seçildi' : 'Resim Yükle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F1F1F),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF111714),
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _kaydet,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF38E07B),
            foregroundColor: const Color(0xFF111714),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}
