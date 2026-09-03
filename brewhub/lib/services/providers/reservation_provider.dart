import 'package:flutter/material.dart';
import '../../models/reservation_model.dart';
import '../../models/table_model.dart';
import '../booking_service.dart';

class ReservationProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<ReservationModel> _userReservations = [];
  List<ReservationModel> get userReservations => _userReservations;

  List<TableModel> _availableTables = [];
  List<TableModel> get availableTables => _availableTables;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Selection states
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1)); // tomorrow default
  DateTime get selectedDate => _selectedDate;

  String _selectedTimeSlot = '7:00 PM'; // default dinner spot
  String get selectedTimeSlot => _selectedTimeSlot;

  int _selectedGuests = 2; // default date
  int get selectedGuests => _selectedGuests;

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Set selected time slot
  void setSelectedTimeSlot(String slot) {
    _selectedTimeSlot = slot;
    notifyListeners();
  }

  // Set selected guests count
  void setSelectedGuests(int guests) {
    _selectedGuests = guests;
    notifyListeners();
  }

  // Check table availability in real time
  Future<void> checkAvailability(String cafeId) async {
    _isLoading = true;
    _error = null;
    _availableTables = [];
    notifyListeners();

    try {
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      _availableTables = await _bookingService.getAvailableTables(
        cafeId,
        dateStr,
        _selectedTimeSlot,
        _selectedGuests,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit table booking
  Future<bool> bookTable({
    required String cafeId,
    required String cafeName,
    required String userId,
    required String userName,
    String? userPhone,
  }) async {
    if (_availableTables.isEmpty) {
      _error = 'No tables available for the selected group size at this time.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      // Pick the first available table (already sorted by capacity)
      final tableToBook = _availableTables.first;

      await _bookingService.createBooking(
        cafeId: cafeId,
        cafeName: cafeName,
        userId: userId,
        userName: userName,
        table: tableToBook,
        date: dateStr,
        timeSlot: _selectedTimeSlot,
        guests: _selectedGuests,
        userPhone: userPhone,
      );

      // Reload user bookings
      await loadUserReservations(userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load bookings list
  Future<void> loadUserReservations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userReservations = await _bookingService.getUserReservations(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel reservation
  Future<void> cancelReservation(String reservationId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bookingService.cancelReservation(reservationId);
      await loadUserReservations(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
