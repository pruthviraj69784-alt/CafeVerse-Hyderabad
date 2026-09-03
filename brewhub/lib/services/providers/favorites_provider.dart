import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  static const String _prefsKey = 'favorite_cafes';
  List<String> _favoriteIds = [];

  List<String> get favoriteIds => _favoriteIds;

  FavoritesProvider() {
    _loadFavorites();
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _favoriteIds = prefs.getStringList(_prefsKey) ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load favorites: $e');
    }
  }

  // Check if cafe is favorited
  bool isFavorite(String cafeId) {
    return _favoriteIds.contains(cafeId);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String cafeId) async {
    if (_favoriteIds.contains(cafeId)) {
      _favoriteIds.remove(cafeId);
    } else {
      _favoriteIds.add(cafeId);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, _favoriteIds);
    } catch (e) {
      debugPrint('Failed to save favorites: $e');
    }
  }
}
