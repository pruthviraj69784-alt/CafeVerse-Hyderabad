import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../firestore_service.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _firestoreService.getAllProducts();
      _filteredProducts = _products;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _firestoreService.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> filterByCategory(String category) async {
    _selectedCategory = category;
    _isLoading = true;
    notifyListeners();

    try {
      if (category.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts =
            await _firestoreService.getProductsByCategory(category);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestoreService.addProduct(product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestoreService.updateProduct(product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestoreService.deleteProduct(productId);
      await loadProducts();
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
