import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../firestore_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<OrderModel>>? _ordersSub;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Create order (called from user-side; admin's side just listens) ──
  Future<bool> createOrder(OrderModel order) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.createOrder(order);
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

  // ── One-time load for the logged-in user's own orders (user panel) ──
  Future<void> loadUserOrders(String userId) async {
    _cancelSubscription();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _firestoreService.getUserOrders(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Real-time stream for ALL orders (Super Admin) ──
  Future<void> loadAllOrders() async {
    _cancelSubscription();
    _isLoading = true;
    _error = null;
    notifyListeners();

    _ordersSub = _firestoreService.getAllOrdersStream().listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Real-time stream for orders of a specific Café (Café Admin) ──
  Future<void> loadOrdersByCafe(String cafeId) async {
    _cancelSubscription();
    _isLoading = true;
    _error = null;
    notifyListeners();

    _ordersSub = _firestoreService.getOrdersByCafeStream(cafeId).listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Update a single order's status ──
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, status);
      // Stream listener will auto-update _orders; but optimistically patch too
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

  void _cancelSubscription() {
    _ordersSub?.cancel();
    _ordersSub = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}
