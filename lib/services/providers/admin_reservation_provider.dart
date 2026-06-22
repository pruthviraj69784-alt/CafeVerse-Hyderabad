import 'dart:async';
import 'package:flutter/material.dart';
import '../firestore_service.dart';
import '../../models/reservation_model.dart';

class AdminReservationProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ReservationModel> _reservations = [];
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'all'; // 'all', 'pending', 'confirmed', 'cancelled', 'completed'

  StreamSubscription<List<ReservationModel>>? _reservationsSub;

  List<ReservationModel> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;

  List<ReservationModel> get filteredReservations {
    if (_filterStatus == 'all') return _reservations;
    return _reservations.where((r) => r.status == _filterStatus).toList();
  }

  int get pendingCount => _reservations.where((r) => r.status == 'pending').length;
  int get confirmedCount => _reservations.where((r) => r.status == 'confirmed').length;
  int get todayCount {
    final today = DateTime.now();
    return _reservations.where((r) {
      final d = r.reservationDate;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).length;
  }

  Future<void> loadReservationsForCafe(String cafeId) async {
    _cancelSubscription();
    _isLoading = true;
    _error = null;
    notifyListeners();

    _reservationsSub = _firestoreService.getReservationsByCafeStream(cafeId).listen(
      (reservations) {
        _reservations = reservations;
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

  Future<void> loadAllReservations() async {
    _cancelSubscription();
    _isLoading = true;
    _error = null;
    notifyListeners();

    _reservationsSub = _firestoreService.getAllReservationsStream().listen(
      (reservations) {
        _reservations = reservations;
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

  Future<bool> updateStatus(String reservationId, String status) async {
    try {
      await _firestoreService.updateReservationStatus(reservationId, status);
      final idx = _reservations.indexWhere((r) => r.id == reservationId);
      if (idx != -1) {
        _reservations[idx] = _reservations[idx].copyWith(status: status);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _cancelSubscription() {
    _reservationsSub?.cancel();
    _reservationsSub = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}
