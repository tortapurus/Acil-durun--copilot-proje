import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String ad;

  @HiveField(2)
  late String kategori;

  @HiveField(3)
  late DateTime sonKullanmaTarihi;

  @HiveField(4)
  late DateTime hatirlatmaTarihi;

  @HiveField(5)
  String? notlar;

  @HiveField(6)
  String? konum;

  @HiveField(7)
  String? resimYolu;

  @HiveField(8)
  bool kontrolEdildi;

  Product({
    required this.id,
    required this.ad,
    required this.kategori,
    required this.sonKullanmaTarihi,
    required this.hatirlatmaTarihi,
    this.notlar,
    this.konum,
    this.resimYolu,
    this.kontrolEdildi = false,
  });

  // Kalan gün hesaplama
  int get kalanGun {
    final now = DateTime.now();
    final difference = sonKullanmaTarihi.difference(now);
    return difference.inDays;
  }

  // Durum (yeşil, sarı, kırmızı)
  ProductStatus get durum {
    final kalan = kalanGun;
    if (kalan <= 0) return ProductStatus.suresiDolmus;
    if (kalan <= 7) return ProductStatus.yakindaBitecek;
    return ProductStatus.guvenli;
  }
}

enum ProductStatus {
  guvenli,      // >7 gün - yeşil
  yakindaBitecek, // 1-7 gün - sarı
  suresiDolmus,   // ≤0 gün - kırmızı
}
