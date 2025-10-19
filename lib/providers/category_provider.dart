import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category.dart' as models;

class CategoryProvider with ChangeNotifier {
  late Box<models.Category> _categoryBox;
  List<models.Category> _categories = [];
  bool _isInitialized = false;

  List<models.Category> get categories => _categories;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _categoryBox = await Hive.openBox<models.Category>('categories');
    
    // İlk açılışta varsayılan kategorileri ekle
    if (_categoryBox.isEmpty) {
      for (var category in models.DefaultCategories.list) {
        await _categoryBox.put(category.id, category);
      }
    }
    
    _categories = _categoryBox.values.toList();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addCategory(models.Category category) async {
    await _categoryBox.put(category.id, category);
    _categories.add(category);
    notifyListeners();
  }

  Future<void> updateCategory(models.Category category) async {
    await _categoryBox.put(category.id, category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    final category = _categories.firstWhere((c) => c.id == id);
    if (!category.varsayilan) {
      await _categoryBox.delete(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    }
  }

  models.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
