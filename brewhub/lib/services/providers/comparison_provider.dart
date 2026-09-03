import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../../models/cafe_model.dart';
import '../../models/product_model.dart';

class ComparisonResult {
  final CafeModel cafe;
  final ProductModel product;
  final double distance;

  ComparisonResult({
    required this.cafe,
    required this.product,
    this.distance = 0.0,
  });
}

class ComparisonProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ComparisonResult> _comparisonResults = [];
  List<ComparisonResult> get comparisonResults => _comparisonResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Perform search and comparison
  Future<void> searchAndCompare(String query, List<CafeModel> loadedCafes, {double? userLat, double? userLng}) async {
    if (query.trim().isEmpty) {
      _comparisonResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _searchQuery = query;
    _comparisonResults = [];
    notifyListeners();

    try {
      // Fetch all products matching the query
      // To perform case-insensitive contains search in Firestore without third-party services:
      // We can fetch all products and filter client-side since the catalog is small, or use a starts-with query.
      // Since it's a seed dataset of ~30 items, client-side filtering is extremely fast, reliable, and case-insensitive!
      final productsSnapshot = await _firestore.collection('products').get();
      final List<ProductModel> matchedProducts = [];

      for (var doc in productsSnapshot.docs) {
        final product = ProductModel.fromMap(doc.data(), doc.id);
        if (product.name.toLowerCase().contains(query.toLowerCase())) {
          matchedProducts.add(product);
        }
      }

      final List<ComparisonResult> results = [];

      // Link products to cafes and calculate distance if coordinates are present
      for (var product in matchedProducts) {
        if (product.cafeId.isEmpty) continue;

        // Find cafe details in preloaded cafes list
        final cafe = loadedCafes.firstWhere(
          (c) => c.id == product.cafeId,
          orElse: () => CafeModel(
            id: product.cafeId,
            name: 'Café (Unknown)',
            area: 'Hyderabad',
            imageUrl: '',
            rating: 0.0,
            costForTwo: 0,
            description: '',
            latitude: 17.4065,
            longitude: 78.4772,
            photoUrls: [],
            ambianceTags: [],
          ),
        );

        if (cafe.name == 'Café (Unknown)') continue;

        double distance = 0.0;
        if (userLat != null && userLng != null) {
          // Haversine formula calculation
          distance = _calculateDistance(userLat, userLng, cafe.latitude, cafe.longitude);
        }

        results.add(ComparisonResult(cafe: cafe, product: product, distance: distance));
      }

      _comparisonResults = results;
    } catch (e) {
      _error = 'Failed to search items: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Haversine formula for calculating distance in km between two lat/long points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // math.pi / 180
    var c = math.cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  // Get index/id of cheapest item
  String? get cheapestCafeId {
    if (_comparisonResults.isEmpty) return null;
    ComparisonResult cheapest = _comparisonResults.first;
    for (var result in _comparisonResults) {
      if (result.product.price < cheapest.product.price) {
        cheapest = result;
      }
    }
    return cheapest.cafe.id;
  }

  // Get index/id of best rated cafe
  String? get bestRatedCafeId {
    if (_comparisonResults.isEmpty) return null;
    ComparisonResult best = _comparisonResults.first;
    for (var result in _comparisonResults) {
      if (result.cafe.rating > best.cafe.rating) {
        best = result;
      }
    }
    return best.cafe.id;
  }

  // Get index/id of nearest cafe
  String? get nearestCafeId {
    final hasDistances = _comparisonResults.any((r) => r.distance > 0.0);
    if (!hasDistances) return null;
    ComparisonResult nearest = _comparisonResults.firstWhere((r) => r.distance > 0.0);
    for (var result in _comparisonResults) {
      if (result.distance > 0.0 && result.distance < nearest.distance) {
        nearest = result;
      }
    }
    return nearest.cafe.id;
  }

  // Sort comparison results
  void sortResults(String criterion) {
    if (_comparisonResults.isEmpty) return;

    if (criterion == 'Price') {
      _comparisonResults.sort((a, b) => a.product.price.compareTo(b.product.price));
    } else if (criterion == 'Rating') {
      _comparisonResults.sort((a, b) => b.cafe.rating.compareTo(a.cafe.rating));
    } else if (criterion == 'Proximity') {
      _comparisonResults.sort((a, b) => a.distance.compareTo(b.distance));
    }
    notifyListeners();
  }
}
