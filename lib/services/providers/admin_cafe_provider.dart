import 'package:flutter/material.dart';
import '../firestore_service.dart';
import '../../models/cafe_model.dart';
import '../../models/user_model.dart';

class AdminCafeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CafeModel> _cafes = [];
  CafeModel? _selectedCafe;
  List<UserModel> _adminUsers = [];
  bool _isLoading = false;
  String? _error;

  List<CafeModel> get cafes => _cafes;
  CafeModel? get selectedCafe => _selectedCafe;
  List<UserModel> get adminUsers => _adminUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCafes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _cafes = await _firestoreService.getAllCafes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCafeById(String cafeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedCafe = await _firestoreService.getCafe(cafeId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAdminUsers() async {
    try {
      _adminUsers = await _firestoreService.getAdminUsers();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> toggleCafeStatus(String cafeId, bool isActive) async {
    try {
      await _firestoreService.setCafeActiveStatus(cafeId, isActive);
      final idx = _cafes.indexWhere((c) => c.id == cafeId);
      if (idx != -1) {
        _cafes[idx] = _cafes[idx].copyWith(isActive: isActive);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignOwner(String cafeId, String ownerId) async {
    try {
      await _firestoreService.assignCafeOwner(cafeId, ownerId);
      final idx = _cafes.indexWhere((c) => c.id == cafeId);
      if (idx != -1) {
        _cafes[idx] = _cafes[idx].copyWith(ownerId: ownerId);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createCafe(CafeModel cafe) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cafeId = await _firestoreService.addCafe(cafe);
      final newCafe = cafe.copyWith(id: cafeId);
      _cafes.add(newCafe);
      notifyListeners();
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

  Future<bool> deleteCafe(String cafeId) async {
    try {
      await _firestoreService.deleteCafe(cafeId);
      _cafes.removeWhere((c) => c.id == cafeId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCafeDetails(String cafeId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateCafe(cafeId, data);
      // Update local list
      final idx = _cafes.indexWhere((c) => c.id == cafeId);
      if (idx != -1) {
        // Also update local list fields
        final updated = CafeModel.fromMap({
          ..._cafes[idx].toMap(),
          ...data,
        }, cafeId);
        _cafes[idx] = updated;
      }
      if (_selectedCafe?.id == cafeId) {
        await loadCafeById(cafeId);
      } else {
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createAdminUser({
    required String name,
    required String email,
    required String password,
    required String cafeId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestoreService.createAdminUser(
        name: name,
        email: email,
        password: password,
        cafeId: cafeId,
      );
      await loadCafes();
      await loadAdminUsers();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
