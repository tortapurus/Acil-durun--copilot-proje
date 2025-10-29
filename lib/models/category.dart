class Category {
  final String id;
  final String name;
  final bool isCustom;
  final String? translationKey;
  final String? iconPath;

  const Category({
    required this.id,
    required this.name,
    this.isCustom = false,
    this.translationKey,
    this.iconPath,
  });

  Category copyWith({
    String? id,
    String? name,
    bool? isCustom,
    String? translationKey,
    String? iconPath,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      translationKey: translationKey ?? this.translationKey,
      iconPath: iconPath ?? this.iconPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isCustom': isCustom,
      'translationKey': translationKey,
      'iconPath': iconPath,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      isCustom: json['isCustom'] ?? false,
      translationKey: json['translationKey'],
      iconPath: json['iconPath'],
    );
  }

  static const List<Category> _fixedCategories = [
    Category(
      id: 'water',
      name: 'Su',
      translationKey: 'categories.fixed.water',
      iconPath: 'assets/icons/icon.png',
    ),
    Category(
      id: 'canned_food',
      name: 'Konserve',
      translationKey: 'categories.fixed.canned_food',
      iconPath: 'assets/icons/icon.png',
    ),
    Category(
      id: 'nuts',
      name: 'Kuru Yemiş',
      translationKey: 'categories.fixed.nuts',
      iconPath: 'assets/icons/icon.png',
    ),
    Category(
      id: 'food',
      name: 'Yiyecek',
      translationKey: 'categories.fixed.food',
      iconPath: 'assets/icons/icon.png',
    ),
    Category(
      id: 'first_aid_kit',
      name: 'İlk yardım çantası',
      translationKey: 'categories.fixed.first_aid_kit',
    ),
    Category(
      id: 'flashlight',
      name: 'El feneri',
      translationKey: 'categories.fixed.flashlight',
    ),
    Category(
      id: 'battery_radio',
      name: 'Pilli radyo',
      translationKey: 'categories.fixed.battery_radio',
    ),
    Category(
      id: 'blanket',
      name: 'Battaniye',
      translationKey: 'categories.fixed.blanket',
    ),
    Category(
      id: 'sleeping_bag',
      name: 'Uyku tulumu',
      translationKey: 'categories.fixed.sleeping_bag',
    ),
    Category(
      id: 'multi_tool',
      name: 'Çok amaçlı çakı',
      translationKey: 'categories.fixed.multi_tool',
    ),
    Category(
      id: 'work_gloves',
      name: 'İş eldiveni',
      translationKey: 'categories.fixed.work_gloves',
    ),
    Category(
      id: 'matches',
      name: 'Kibrit',
      translationKey: 'categories.fixed.matches',
    ),
    Category(
      id: 'lighter',
      name: 'Çakmak',
      translationKey: 'categories.fixed.lighter',
    ),
    Category(
      id: 'dust_mask',
      name: 'Toz maskesi',
      translationKey: 'categories.fixed.dust_mask',
    ),
    Category(
      id: 'wet_wipes',
      name: 'Islak mendil',
      translationKey: 'categories.fixed.wet_wipes',
    ),
    Category(
      id: 'toilet_paper',
      name: 'Tuvalet kağıdı',
      translationKey: 'categories.fixed.toilet_paper',
    ),
    Category(
      id: 'sanitary_pad',
      name: 'Hijyenik ped',
      translationKey: 'categories.fixed.sanitary_pad',
    ),
    Category(
      id: 'documents',
      name: 'Kimlik, tapu, sigorta, pasaport',
      translationKey: 'categories.fixed.documents',
    ),
    Category(
      id: 'cash',
      name: 'Nakit para',
      translationKey: 'categories.fixed.cash',
    ),
    Category(
      id: 'spare_clothes',
      name: 'Yedek kıyafet',
      translationKey: 'categories.fixed.spare_clothes',
    ),
    Category(
      id: 'trash_bag',
      name: 'Çöp torbası',
      translationKey: 'categories.fixed.trash_bag',
    ),
    Category(
      id: 'soap',
      name: 'Sabun',
      translationKey: 'categories.fixed.soap',
    ),
    Category(
      id: 'toothbrush_toothpaste',
      name: 'Diş fırçası ve macunu',
      translationKey: 'categories.fixed.toothbrush_toothpaste',
    ),
    Category(
      id: 'water_purification_tablets',
      name: 'Su Arıtma Tabletleri',
      translationKey: 'categories.fixed.water_purification_tablets',
    ),
    Category(
      id: 'water_purifier',
      name: 'Su arıtma cihazı',
      translationKey: 'categories.fixed.water_purifier',
    ),
    Category(
      id: 'compass_map',
      name: 'Pusula ve Harita',
      translationKey: 'categories.fixed.compass_map',
    ),
    Category(
      id: 'handgun',
      name: 'Tabanca',
      translationKey: 'categories.fixed.handgun',
    ),
    Category(
      id: 'handgun_ammo',
      name: 'Tabanca Mermisi',
      translationKey: 'categories.fixed.handgun_ammo',
    ),
    Category(
      id: 'rifle',
      name: 'Tüfek',
      translationKey: 'categories.fixed.rifle',
    ),
    Category(
      id: 'rifle_ammo',
      name: 'Tüfek Mermisi',
      translationKey: 'categories.fixed.rifle_ammo',
    ),
    // Removed ammo subcategories (slug/shot/lead-free) per product policy request.
  ];

  static List<Category> get fixedCategories =>
      List<Category>.from(_fixedCategories);
}
