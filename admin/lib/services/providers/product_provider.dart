import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../firestore_service.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _categories = [];
  String? _selectedCategory;
  String? _currentCafeId;
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products =>
      _selectedCategory != null && _selectedCategory!.isNotEmpty
          ? _filteredProducts
          : _products;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all products (Super Admin)
  Future<void> loadProducts() async {
    _currentCafeId = null;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _firestoreService.getAllProducts();
      _filteredProducts = _products;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load products for a specific café (Café Admin)
  Future<void> loadProductsByCafe(String cafeId) async {
    _currentCafeId = cafeId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _firestoreService.getProductsByCafe(cafeId);
      _filteredProducts = _products;
      _categories = await _firestoreService.getCategories(cafeId: cafeId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _firestoreService.getCategories(cafeId: _currentCafeId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category.isEmpty ? null : category;
    if (_selectedCategory == null) {
      _filteredProducts = _products;
    } else {
      _filteredProducts =
          _products.where((p) => p.category == _selectedCategory).toList();
    }
    notifyListeners();
  }

  Future<void> _reload() async {
    if (_currentCafeId != null) {
      await loadProductsByCafe(_currentCafeId!);
    } else {
      await loadProducts();
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestoreService.addProduct(product);
      await _reload();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestoreService.updateProduct(product);
      await _reload();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestoreService.deleteProduct(productId);
      await _reload();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
