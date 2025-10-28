import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../models/product.dart';
import '../models/bag.dart';
import '../models/category.dart';
import '../models/depot.dart';
import 'localization_service.dart';

class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  static DataService get instance => _instance;

  final List<Product> _products = [];
  final List<Bag> _bags = [];
  final List<Depot> _depots = [];
  final List<Category> _categories = [];

  factory DataService() {
    return _instance;
  }

  DataService._internal();

  // Products Management
  List<Product> get products => _products;

  void addProduct(Product product) {
    _products.add(product);
    _attachProductToLocation(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      final previous = _products[index];
      _detachProductFromLocation(previous);
      _products[index] = product;
      _attachProductToLocation(product);
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    final productIndex = _products.indexWhere((p) => p.id == productId);
    if (productIndex == -1) {
      return;
    }

    final Product product = _products[productIndex];
    _detachProductFromLocation(product);
    _products.removeAt(productIndex);
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getExpiredProducts() {
    return _products.where((p) => p.isExpired).toList();
  }

  List<Product> getExpiringProducts() {
    return _products.where((p) => p.isExpiringsSoon).toList();
  }

  // Bags Management
  List<Bag> get bags => _bags;

  void addBag(Bag bag) {
    _bags.add(bag);
    notifyListeners();
  }

  void updateBag(Bag bag) {
    final index = _bags.indexWhere((b) => b.id == bag.id);
    if (index != -1) {
      _bags[index] = bag;
      notifyListeners();
    }
  }

  void deleteBag(String bagId) {
    _bags.removeWhere((b) => b.id == bagId);
    notifyListeners();
  }

  Bag? getBagById(String id) {
    try {
      return _bags.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsInBag(String bagId) {
    return _products
        .where((product) =>
            product.storageType == StorageLocationType.bag &&
            product.storageId == bagId)
        .toList();
  }

  // Depots Management
  List<Depot> get depots => _depots;

  void addDepot(Depot depot) {
    _depots.add(depot);
    notifyListeners();
  }

  void updateDepot(Depot depot) {
    final index = _depots.indexWhere((d) => d.id == depot.id);
    if (index != -1) {
      _depots[index] = depot;
      notifyListeners();
    }
  }

  void deleteDepot(String depotId) {
    _depots.removeWhere((d) => d.id == depotId);
    notifyListeners();
  }

  Depot? getDepotById(String id) {
    try {
      return _depots.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsInDepot(String depotId) {
    return _products
        .where((product) =>
            product.storageType == StorageLocationType.depot &&
            product.storageId == depotId)
        .toList();
  }

  // Categories Management
  List<Category> get allCategories {
    final categories = <Category>[];
    categories.addAll(Category.fixedCategories);
    categories.addAll(_categories.where((c) => c.isCustom));
    return categories;
  }

  List<Category> get customCategories =>
      _categories.where((category) => category.isCustom).toList(growable: false);

  void addCustomCategory(Category category) {
    final normalizedName = category.name.toLowerCase().trim();
    if (!_categories.any((c) => c.name.toLowerCase().trim() == normalizedName)) {
      _categories.add(category);
      notifyListeners();
    }
  }

  void deleteCustomCategory(String categoryId) {
    _categories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
  }

  // Statistics
  int get totalProductCount => _products.length;

  int get emergencyBagCount => _bags.where((b) => b.isEmergencyBag).length;

  int get expiredProductCount => getExpiredProducts().length;

  int get expiringProductCount => getExpiringProducts().length;

  int get outOfStockProductCount =>
      _products.where((product) => product.stock <= 0).length;

  int get totalBagCount => _bags.length;

  // Search
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.categoryId.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Category? findCategoryById(String categoryId) {
    try {
      return allCategories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  String resolveCategoryLabel(
    String categoryId,
    LocalizationService loc,
  ) {
    final category = findCategoryById(categoryId);
    if (category == null) {
      return categoryId;
    }

    if (category.translationKey != null) {
      return loc.t(category.translationKey!);
    }

    return category.name;
  }

  void _attachProductToLocation(Product product) {
    if (product.storageId == null || product.storageType == null) {
      return;
    }

    switch (product.storageType!) {
      case StorageLocationType.bag:
        final int bagIndex = _bags.indexWhere((bag) => bag.id == product.storageId);
        if (bagIndex != -1) {
          final bag = _bags[bagIndex];
          if (!bag.productIds.contains(product.id)) {
            final updated = List<String>.from(bag.productIds)..add(product.id);
            _bags[bagIndex] = bag.copyWith(productIds: updated);
          }
        }
        break;
      case StorageLocationType.depot:
        final int depotIndex =
            _depots.indexWhere((depot) => depot.id == product.storageId);
        if (depotIndex != -1) {
          final depot = _depots[depotIndex];
          if (!depot.productIds.contains(product.id)) {
            final updated = List<String>.from(depot.productIds)..add(product.id);
            _depots[depotIndex] = depot.copyWith(productIds: updated);
          }
        }
        break;
    }
  }

  void _detachProductFromLocation(Product product) {
    if (product.storageId == null || product.storageType == null) {
      return;
    }

    switch (product.storageType!) {
      case StorageLocationType.bag:
        final int bagIndex = _bags.indexWhere((bag) => bag.id == product.storageId);
        if (bagIndex != -1) {
          final bag = _bags[bagIndex];
          final updated = List<String>.from(bag.productIds)
            ..remove(product.id);
          _bags[bagIndex] = bag.copyWith(productIds: updated);
        }
        break;
      case StorageLocationType.depot:
        final int depotIndex =
            _depots.indexWhere((depot) => depot.id == product.storageId);
        if (depotIndex != -1) {
          final depot = _depots[depotIndex];
          final updated = List<String>.from(depot.productIds)
            ..remove(product.id);
          _depots[depotIndex] = depot.copyWith(productIds: updated);
        }
        break;
    }
  }

  bool get hasAnyData =>
      _products.isNotEmpty || _bags.isNotEmpty || _depots.isNotEmpty || _categories.isNotEmpty;

  Map<String, dynamic> exportSnapshot() {
    return {
      'version': 1,
      'generatedAt': DateTime.now().toIso8601String(),
      'products': _products.map((product) => product.toJson()).toList(),
      'bags': _bags.map((bag) => bag.toJson()).toList(),
      'depots': _depots.map((depot) => depot.toJson()).toList(),
      'customCategories':
          _categories.where((category) => category.isCustom).map((category) => category.toJson()).toList(),
    };
  }

  Future<void> importSnapshot(Map<String, dynamic> snapshot) async {
    List<Map<String, dynamic>> coerceList(dynamic source) {
      if (source is List) {
        return source
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      return <Map<String, dynamic>>[];
    }

    _products.clear();
    _bags.clear();
    _depots.clear();
    _categories.clear();

  final bagList = coerceList(snapshot['bags']);
    for (final bagJson in bagList) {
      final bag = Bag.fromJson(bagJson).copyWith(productIds: const <String>[]);
      _bags.add(bag);
    }

  final depotList = coerceList(snapshot['depots']);
    for (final depotJson in depotList) {
      final depot = Depot.fromJson(depotJson).copyWith(productIds: const <String>[]);
      _depots.add(depot);
    }

  final categoryList = coerceList(snapshot['customCategories']);
    for (final categoryJson in categoryList) {
      final category = Category.fromJson(categoryJson).copyWith(isCustom: true);
      _categories.add(category);
    }

  final productList = coerceList(snapshot['products']);
    for (final productJson in productList) {
      final product = Product.fromJson(productJson);
      _products.add(product);
      _attachProductToLocation(product);
    }

    notifyListeners();
  }
}
