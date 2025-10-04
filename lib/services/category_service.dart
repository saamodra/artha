import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;
import '../models/wallet_record.dart';
import '../repositories/category_repository.dart';

class CategoryService extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();

  List<models.Category> _allCategories = [];
  bool _isLoading = false;
  String? _error;

  List<models.Category> get allCategories => _allCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the service by loading all categories
  Future<void> initialize() async {
    await loadCategories();
  }

  /// Load all categories from the repository
  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      _allCategories = await _repository.getAllCategories();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get all categories (no filtering by type)
  List<models.Category> getAllCategories() {
    return _allCategories;
  }

  /// Get all category names (no filtering by type)
  List<String> getAllCategoryNames() {
    return _allCategories.map((category) => category.name).toList();
  }

  /// Get categories filtered by record type (for backward compatibility)
  /// Now returns all categories since there's no difference between types
  List<models.Category> getCategoriesForType(RecordType type) {
    // If no categories loaded from database, return empty list
    if (_allCategories.isEmpty) {
      return [];
    }
    return _allCategories;
  }

  /// Get category names for a specific type (for backward compatibility)
  /// Now returns all category names since there's no difference between types
  List<String> getCategoryNamesForType(RecordType type) {
    // If no categories loaded from database, return empty list
    if (_allCategories.isEmpty) {
      return [];
    }
    return _allCategories.map((category) => category.name).toList();
  }

  /// Find a category by name
  models.Category? findCategoryByName(String name) {
    try {
      return _allCategories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Create a new category
  Future<models.Category?> createCategory(String name) async {
    _setLoading(true);
    _clearError();

    try {
      final category = await _repository.createCategory(name);
      _allCategories.add(category);
      _allCategories.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return category;
    } catch (e) {
      _setError('Failed to create category: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing category
  Future<models.Category?> updateCategory(String id, String name) async {
    _setLoading(true);
    _clearError();

    try {
      final category = await _repository.updateCategory(id, name);
      final index = _allCategories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _allCategories[index] = category;
        _allCategories.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
      }
      return category;
    } catch (e) {
      _setError('Failed to update category: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteCategory(id);
      _allCategories.removeWhere((category) => category.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh categories from the database
  Future<void> refresh() async {
    await loadCategories();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
