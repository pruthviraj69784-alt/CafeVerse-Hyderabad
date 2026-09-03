import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../firestore_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createOrder(OrderModel order, String cafeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.createOrder(order, cafeId);
      await loadUserOrders(order.userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _firestoreService.getUserOrders(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _firestoreService.getAllOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, status);
      // Update local state
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
        notifyListeners();
      }
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
