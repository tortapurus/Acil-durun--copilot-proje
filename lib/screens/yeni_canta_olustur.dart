import 'package:flutter/material.dart';

class YeniCantaOlustur extends StatefulWidget {
  const YeniCantaOlustur({super.key});

  @override
  State<YeniCantaOlustur> createState() => _YeniCantaOlusturState();
}

class _YeniCantaOlusturState extends State<YeniCantaOlustur> {
  final _formKey = GlobalKey<FormState>();
  final _cantaAdiController = TextEditingController();
  final _notlarController = TextEditingController();

  @override
  void dispose() {
    _cantaAdiController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  void _cantaOlustur() {
    if (_formKey.currentState!.validate()) {
      // Çanta oluşturma işlemi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_cantaAdiController.text} oluşturuldu!'),
          backgroundColor: const Color(0xFF994CE6),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A181D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A181D),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Yeni Çanta Oluştur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Çanta İkonu
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF994CE6).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    size: 50,
                    color: Color(0xFF994CE6),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Çanta Adı
              const Text(
                'Çanta Adı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cantaAdiController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Örn: Ev Acil Durum Çantası',
                  hintStyle: const TextStyle(color: Color(0xFF666666)),
                  filled: true,
                  fillColor: const Color(0xFF2A2730),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF994CE6), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Çanta adı gereklidir';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Notlar (İsteğe Bağlı)
              const Text(
                'Notlar (İsteğe Bağlı)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notlarController,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Çanta hakkında notlar ekleyin...',
                  hintStyle: const TextStyle(color: Color(0xFF666666)),
                  filled: true,
                  fillColor: const Color(0xFF2A2730),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF994CE6), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 32),

              // Bilgilendirme Kutusu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF994CE6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF994CE6).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF994CE6),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Oluşturduğunuz çantaya daha sonra ürün ekleyebilirsiniz.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A181D),
          border: Border(top: BorderSide(color: Color(0xFF333333))),
        ),
        child: ElevatedButton(
          onPressed: _cantaOlustur,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF994CE6), // primary-purple
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            shadowColor: const Color(0xFF994CE6).withOpacity(0.5),
          ),
          child: const Text(
            'Çantayı Oluştur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
