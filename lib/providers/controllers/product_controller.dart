import 'package:flutter/foundation.dart';
import '../../models/product_model.dart';
import '../../data/database_helper.dart';

class ProductProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<ProductModel> _products = [];
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  final Set<int> _favoriteProductIds = <int>{};
  String? _currentUserEmail;
  int? _pendingFavoriteProductId;

  int? get pendingFavoriteProductId => _pendingFavoriteProductId;

  void setPendingFavorite(int? productId) {
    _pendingFavoriteProductId = productId;
  }

  void clearPendingFavorite() {
    _pendingFavoriteProductId = null;
  }

  Future<void> loadUserFavorites(String? email) async {
    _currentUserEmail = email?.trim().toLowerCase();
    _favoriteProductIds.clear();
    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      final favIds = await _dbHelper.getFavorites(_currentUserEmail!);
      _favoriteProductIds.addAll(favIds);
      if (_pendingFavoriteProductId != null) {
        final pending = _pendingFavoriteProductId!;
        _pendingFavoriteProductId = null;
        if (!_favoriteProductIds.contains(pending)) {
          _favoriteProductIds.add(pending);
          await _dbHelper.addFavorite(_currentUserEmail!, pending);
        }
      }
    }
    notifyListeners();
  }

  void clearUserFavorites() {
    _currentUserEmail = null;
    _favoriteProductIds.clear();
    _pendingFavoriteProductId = null;
    notifyListeners();
  }

  List<ProductModel> get allProducts {
    final list = List<ProductModel>.from(_products);
    list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return list;
  }

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<int> get favoriteProductIds => _favoriteProductIds;

  bool isFavorite(int? productId) {
    if (productId == null) return false;
    return _favoriteProductIds.contains(productId);
  }

  Future<bool> toggleFavorite(int? productId, {String? userEmail}) async {
    if (productId == null) return false;
    final email = (userEmail ?? _currentUserEmail)?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      _pendingFavoriteProductId = productId;
      return false;
    }
    _currentUserEmail = email;
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
      await _dbHelper.removeFavorite(email, productId);
    } else {
      _favoriteProductIds.add(productId);
      await _dbHelper.addFavorite(email, productId);
    }
    notifyListeners();
    return true;
  }

  List<ProductModel> get favoriteProducts {
    return _products.where((p) => _favoriteProductIds.contains(p.id)).toList();
  }

  List<String> _categories = ['Mujer', 'Hombre', 'Unisex', 'Sets'];

  List<String> get availableCategories => ['Todos', ..._categories];

  List<ProductModel> get filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    final list = _products.where((product) {
      final matchesCategory = _selectedCategory == 'Todos' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.origin.toLowerCase().contains(query) ||
          product.variety.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.presentation.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
    list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return list;
  }

  List<ProductModel> get searchResults {
    final query = _searchQuery.trim().toLowerCase();
    final list = (query.isEmpty
            ? List<ProductModel>.from(_products)
            : _products.where((product) {
                return product.name.toLowerCase().contains(query) ||
                    product.category.toLowerCase().contains(query) ||
                    product.origin.toLowerCase().contains(query) ||
                    product.variety.toLowerCase().contains(query) ||
                    product.description.toLowerCase().contains(query) ||
                    product.presentation.toLowerCase().contains(query);
              }).toList())
      ..sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return list;
  }

  List<ProductModel> get lowStockProducts {
    return _products.where((p) => p.isLowStock).toList();
  }

  Future<void> loadCategories() async {
    try {
      final cats = await _dbHelper.getCategories();
      if (cats.isNotEmpty) {
        _categories = cats;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> addCategory(String category) async {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return false;

    if (_categories.any((c) => c.toLowerCase() == trimmed.toLowerCase())) {
      _errorMessage = 'La categoría "$trimmed" ya existe.';
      notifyListeners();
      return false;
    }

    final success = await _dbHelper.insertCategory(trimmed);
    if (success) {
      _categories.add(trimmed);
      notifyListeners();
      return true;
    }
    return false;
  }

  int getProductCountForCategory(String category) {
    if (category.toLowerCase() == 'todos') return _products.length;
    return _products
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .length;
  }

  Future<bool> renameCategory(String oldName, String newName) async {
    final trimmedOld = oldName.trim();
    final trimmedNew = newName.trim();
    if (trimmedOld.isEmpty || trimmedNew.isEmpty) return false;
    if (trimmedOld.toLowerCase() == trimmedNew.toLowerCase()) return true;

    if (_categories.any((c) => c.toLowerCase() == trimmedNew.toLowerCase())) {
      _errorMessage = 'La categoría "$trimmedNew" ya existe.';
      notifyListeners();
      return false;
    }

    final success = await _dbHelper.updateCategory(trimmedOld, trimmedNew);
    if (success) {
      final index = _categories
          .indexWhere((c) => c.toLowerCase() == trimmedOld.toLowerCase());
      if (index != -1) {
        _categories[index] = trimmedNew;
      }
      if (_selectedCategory.toLowerCase() == trimmedOld.toLowerCase()) {
        _selectedCategory = trimmedNew;
      }
      // Actualizar productos en memoria
      for (int i = 0; i < _products.length; i++) {
        if (_products[i].category.toLowerCase() == trimmedOld.toLowerCase()) {
          _products[i] = _products[i].copyWith(category: trimmedNew);
        }
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteCategory(String category) async {
    final trimmed = category.trim();
    if (getProductCountForCategory(trimmed) > 0) {
      _errorMessage =
          'No se puede eliminar la categoría "$trimmed" porque contiene perfumes asociados.';
      notifyListeners();
      return false;
    }

    final fallback = _categories.firstWhere(
      (c) => c.toLowerCase() != trimmed.toLowerCase(),
      orElse: () => 'Unisex',
    );

    final success =
        await _dbHelper.deleteCategory(trimmed, fallbackCategory: fallback);
    if (success) {
      _categories.removeWhere((c) => c.toLowerCase() == trimmed.toLowerCase());
      if (_selectedCategory.toLowerCase() == trimmed.toLowerCase()) {
        _selectedCategory = 'Todos';
      }
      // Actualizar productos en memoria que tenían esa categoría
      for (int i = 0; i < _products.length; i++) {
        if (_products[i].category.toLowerCase() == trimmed.toLowerCase()) {
          _products[i] = _products[i].copyWith(category: fallback);
        }
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> loadProducts() async {
    if (_products.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      await loadCategories();
      _products = await _dbHelper.getProducts();
      _products.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar perfumes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> addProduct(ProductModel product) async {
    try {
      final id = await _dbHelper.insertProduct(product);
      final newProduct = product.copyWith(id: id);
      _products.insert(0, newProduct);
      _products.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al agregar perfume: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _dbHelper.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar perfume: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _dbHelper.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar perfume: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
