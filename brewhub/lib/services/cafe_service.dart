import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cafe_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

class CafeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all cafes — only active & approved ones are shown to customers.
  // Cafes written by the admin app include isActive/isApproved flags;
  // legacy seeded cafes default to true for both.
  Future<List<CafeModel>> getCafes() async {
    try {
      final snapshot = await _firestore.collection('cafes').get();
      return snapshot.docs
          .map((doc) => CafeModel.fromMap(doc.data(), doc.id))
          // Hide cafes blocked or not yet approved by the super admin
          .where((cafe) => cafe.isActive && cafe.isApproved)
          .toList();
    } catch (e) {
      throw 'Failed to fetch cafes: $e';
    }
  }

  // Stream all cafes (active & approved only)
  Stream<List<CafeModel>> getCafesStream() {
    return _firestore.collection('cafes').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CafeModel.fromMap(doc.data(), doc.id))
          .where((cafe) => cafe.isActive && cafe.isApproved)
          .toList();
    });
  }

  // Fetch single cafe — returns null if not active/approved
  Future<CafeModel?> getCafeById(String id) async {
    try {
      final doc = await _firestore.collection('cafes').doc(id).get();
      if (doc.exists) {
        final cafe = CafeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        if (!cafe.isActive || !cafe.isApproved) return null;
        return cafe;
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch cafe details: $e';
    }
  }

  // Fetch menu products for a specific cafe
  Future<List<ProductModel>> getCafeProducts(String cafeId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('cafeId', isEqualTo: cafeId)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch products for cafe $cafeId: $e';
    }
  }

  // Stream menu products for a specific cafe
  Stream<List<ProductModel>> getCafeProductsStream(String cafeId) {
    return _firestore
        .collection('products')
        .where('cafeId', isEqualTo: cafeId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Fetch reviews for a specific cafe
  Future<List<ReviewModel>> getCafeReviews(String cafeId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('cafeId', isEqualTo: cafeId)
          .get();
      final list = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      throw 'Failed to fetch reviews for cafe $cafeId: $e';
    }
  }

  // Stream reviews for a specific cafe
  Stream<List<ReviewModel>> getCafeReviewsStream(String cafeId) {
    return _firestore
        .collection('reviews')
        .where('cafeId', isEqualTo: cafeId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
