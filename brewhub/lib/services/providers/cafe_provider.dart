import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../../models/cafe_model.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';
import '../cafe_service.dart';

class CafeProvider with ChangeNotifier {
  final CafeService _cafeService = CafeService();

  List<CafeModel> _cafes = [];
  List<CafeModel> get cafes => _cafes;

  List<ProductModel> _selectedCafeProducts = [];
  List<ProductModel> get selectedCafeProducts => _selectedCafeProducts;

  List<ReviewModel> _selectedCafeReviews = [];
  List<ReviewModel> get selectedCafeReviews => _selectedCafeReviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedArea = 'All';
  String get selectedArea => _selectedArea;

  String _selectedBudget = 'All'; // All, Under ₹500, ₹500 - ₹1000, ₹1000+
  String get selectedBudget => _selectedBudget;

  String _selectedAmbiance = 'All'; // All, or specific tags
  String get selectedAmbiance => _selectedAmbiance;

  double? _userLat;
  double? _userLng;
  double? get userLat => _userLat;
  double? get userLng => _userLng;

  // Check permissions & get current coordinates
  Future<void> determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      } 

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      _userLat = position.latitude;
      _userLng = position.longitude;
      debugPrint('Location determined: $_userLat, $_userLng');
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  // Fetch all cafes
  Future<void> loadCafes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await determinePosition(); // attempt to get location first
      _cafes = await _cafeService.getCafes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load menu products for a specific cafe
  Future<void> loadCafeProducts(String cafeId) async {
    _isLoading = true;
    _error = null;
    _selectedCafeProducts = [];
    notifyListeners();

    try {
      _selectedCafeProducts = await _cafeService.getCafeProducts(cafeId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load reviews for a specific cafe
  Future<void> loadCafeReviews(String cafeId) async {
    _isLoading = true;
    _error = null;
    _selectedCafeReviews = [];
    notifyListeners();

    try {
      _selectedCafeReviews = await _cafeService.getCafeReviews(cafeId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter cafes list based on current selection
  List<CafeModel> get filteredCafes {
    final list = _cafes.where((cafe) {
      // 1. Search Query filter
      final matchesSearch = cafe.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cafe.area.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cafe.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // 2. Area filter
      final matchesArea = _selectedArea == 'All' || cafe.area == _selectedArea;

      // 3. Budget filter
      bool matchesBudget = true;
      if (_selectedBudget == 'Under ₹500') {
        matchesBudget = cafe.costForTwo < 500;
      } else if (_selectedBudget == '₹500 - ₹1000') {
        matchesBudget = cafe.costForTwo >= 500 && cafe.costForTwo <= 1000;
      } else if (_selectedBudget == '₹1000+') {
        matchesBudget = cafe.costForTwo > 1000;
      }

      // 4. Ambiance filter
      final matchesAmbiance = _selectedAmbiance == 'All' || cafe.ambianceTags.contains(_selectedAmbiance);

      return matchesSearch && matchesArea && matchesBudget && matchesAmbiance;
    }).toList();

    // Sort by proximity/distance if location is available
    if (_userLat != null && _userLng != null) {
      list.sort((a, b) {
        final distA = getDistanceToCafe(a);
        final distB = getDistanceToCafe(b);
        return distA.compareTo(distB);
      });
    }

    return list;
  }

  // Haversine distance helper to cafe in km
  double getDistanceToCafe(CafeModel cafe) {
    if (_userLat == null || _userLng == null) return 0.0;
    var p = 0.017453292519943295; // math.pi / 180
    var c = math.cos;
    var a = 0.5 -
        c((cafe.latitude - _userLat!) * p) / 2 +
        c(_userLat! * p) * c(cafe.latitude * p) * (1 - c((cafe.longitude - _userLng!) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // distance in km
  }

  // Get distinct areas in Hyderabad from seeded cafes
  List<String> get areas {
    final Set<String> allAreas = {'All'};
    for (var cafe in _cafes) {
      allAreas.add(cafe.area);
    }
    return allAreas.toList()..sort();
  }

  // Get distinct ambiance tags
  List<String> get ambianceTags {
    final Set<String> allTags = {'All'};
    for (var cafe in _cafes) {
      allTags.addAll(cafe.ambianceTags);
    }
    return allTags.toList()..sort();
  }

  // Setters and state controllers
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectArea(String area) {
    _selectedArea = area;
    notifyListeners();
  }

  void selectBudget(String budget) {
    _selectedBudget = budget;
    notifyListeners();
  }

  void selectAmbiance(String ambiance) {
    _selectedAmbiance = ambiance;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedArea = 'All';
    _selectedBudget = 'All';
    _selectedAmbiance = 'All';
    notifyListeners();
  }
}
