import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  late Box<Product> _productBox;
  List<Product> _products = [];
  bool _isInitialized = false;

  List<Product> get products => _products;
  bool get isInitialized => _isInitialized;

  // Uyarılar
  List<Product> get suresiDolmusUrunler =>
      _products.where((p) => p.durum == ProductStatus.suresiDolmus).toList();

  List<Product> get yakindaBitecekUrunler =>
      _products.where((p) => p.durum == ProductStatus.yakindaBitecek).toList();

  List<Product> get guvenliUrunler =>
      _products.where((p) => p.durum == ProductStatus.guvenli).toList();

  Future<void> init() async {
    _productBox = await Hive.openBox<Product>('products');
    _products = _productBox.values.toList();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _productBox.put(product.id, product);
    _products.add(product);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await _productBox.put(product.id, product);
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await _productBox.delete(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String kategori) {
    return _products.where((p) => p.kategori == kategori).toList();
  }
}
