import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String ad;

  @HiveField(2)
  late String ikonKodu;

  @HiveField(3)
  bool varsayilan;

  Category({
    required this.id,
    required this.ad,
    required this.ikonKodu,
    this.varsayilan = false,
  });
}

// Varsayılan kategoriler - 02_ui-structure.md'den
class DefaultCategories {
  static List<Category> get list => [
        Category(id: 'su', ad: 'Su', ikonKodu: 'water_drop', varsayilan: true),
        Category(id: 'konserve', ad: 'Konserve', ikonKodu: 'inventory', varsayilan: true),
        Category(id: 'kuru_yemis', ad: 'Kuru Yemiş', ikonKodu: 'restaurant', varsayilan: true),
        Category(id: 'yiyecek', ad: 'Yiyecek', ikonKodu: 'fastfood', varsayilan: true),
        Category(id: 'ilk_yardim', ad: 'İlk yardım çantası', ikonKodu: 'medical_services', varsayilan: true),
        Category(id: 'el_feneri', ad: 'El feneri', ikonKodu: 'flashlight_on', varsayilan: true),
        Category(id: 'pilli_radyo', ad: 'Pilli radyo', ikonKodu: 'radio', varsayilan: true),
        Category(id: 'battaniye', ad: 'Battaniye', ikonKodu: 'bed', varsayilan: true),
        Category(id: 'uyku_tulumu', ad: 'Uyku tulumu', ikonKodu: 'hotel', varsayilan: true),
        Category(id: 'cakı', ad: 'Çok amaçlı çakı', ikonKodu: 'construction', varsayilan: true),
        Category(id: 'eldiven', ad: 'İş eldiveni', ikonKodu: 'front_hand', varsayilan: true),
        Category(id: 'kibrit', ad: 'Kibrit', ikonKodu: 'local_fire_department', varsayilan: true),
        Category(id: 'cakmak', ad: 'Çakmak', ikonKodu: 'whatshot', varsayilan: true),
        Category(id: 'maske', ad: 'Toz maskesi', ikonKodu: 'masks', varsayilan: true),
        Category(id: 'islak_mendil', ad: 'Islak mendil', ikonKodu: 'cleaning_services', varsayilan: true),
        Category(id: 'tuvalet_kagidi', ad: 'Tuvalet kağıdı', ikonKodu: 'bathroom', varsayilan: true),
        Category(id: 'hijyenik_ped', ad: 'Hijyenik ped', ikonKodu: 'favorite', varsayilan: true),
        Category(id: 'evraklar', ad: 'Kimlik, tapu, sigorta, pasaport', ikonKodu: 'description', varsayilan: true),
        Category(id: 'nakit', ad: 'Nakit para', ikonKodu: 'payments', varsayilan: true),
        Category(id: 'kiyafet', ad: 'Yedek kıyafet', ikonKodu: 'checkroom', varsayilan: true),
        Category(id: 'cop_torbasi', ad: 'Çöp torbası', ikonKodu: 'delete', varsayilan: true),
        Category(id: 'sabun', ad: 'Sabun', ikonKodu: 'soap', varsayilan: true),
        Category(id: 'dis_fircasi', ad: 'Diş fırçası ve macunu', ikonKodu: 'medication', varsayilan: true),
        Category(id: 'su_aritma_tablet', ad: 'Su Arıtma Tabletleri', ikonKodu: 'water', varsayilan: true),
        Category(id: 'su_aritma_cihazi', ad: 'Su arıtma cihazı', ikonKodu: 'water_drop', varsayilan: true),
        Category(id: 'pusula_harita', ad: 'Pusula ve Harita', ikonKodu: 'map', varsayilan: true),
        Category(id: 'tabanca', ad: 'Tabanca', ikonKodu: 'gavel', varsayilan: true),
        Category(id: 'tabanca_mermisi', ad: 'Tabanca Mermisi', ikonKodu: 'circle', varsayilan: true),
        Category(id: 'tufek', ad: 'Tüfek', ikonKodu: 'gavel', varsayilan: true),
        Category(id: 'tufek_mermisi', ad: 'Tüfek Mermisi', ikonKodu: 'circle', varsayilan: true),
        Category(id: 'slug_mermi', ad: 'Slug mermiler', ikonKodu: 'circle', varsayilan: true),
        Category(id: 'sacma_mermi', ad: 'Saçma mermiler', ikonKodu: 'circle', varsayilan: true),
        Category(id: 'kursun_mermi', ad: 'Kurşunsuz mermiler', ikonKodu: 'circle', varsayilan: true),
      ];
}
