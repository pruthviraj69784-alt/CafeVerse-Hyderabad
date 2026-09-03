import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _cartItems = [];

  List<CartItemModel> get cartItems => _cartItems;

  double get totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount => _cartItems.length;

  void addToCart(CartItemModel item) {
    final existingIndex =
        _cartItems.indexWhere((i) => i.product.id == item.product.id);

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += item.quantity;
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _cartItems.indexWhere((i) => i.product.id == productId);
    if (index != -1) {
      _cartItems[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  CartItemModel? getCartItem(String productId) {
    try {
      return _cartItems.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }
}
