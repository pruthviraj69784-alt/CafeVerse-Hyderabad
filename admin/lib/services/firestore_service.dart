import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cafe_model.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============ IMAGE UPLOAD ============

  Future<String> uploadProductImage(XFile imageFile) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final Reference ref = _storage.ref().child('product_images').child(fileName);

      String getContentType(String name) {
        final lower = name.toLowerCase();
        if (lower.endsWith('.png')) return 'image/png';
        if (lower.endsWith('.gif')) return 'image/gif';
        return 'image/jpeg';
      }

      final contentType = getContentType(imageFile.name);
      debugPrint('uploadProductImage: target path=${ref.fullPath}, contentType=$contentType');

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: contentType));
      } else {
        final file = File(imageFile.path);
        if (await file.exists()) {
          await ref.putFile(file, SettableMetadata(contentType: contentType));
        } else {
          final bytes = await imageFile.readAsBytes();
          await ref.putData(bytes, SettableMetadata(contentType: contentType));
        }
      }

      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw 'Failed to upload image: ${e.code} ${e.message}';
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  // ============ CAFES ============

  Future<List<CafeModel>> getAllCafes() async {
    try {
      final snapshot = await _firestore.collection('cafes').orderBy('name').get();
      return snapshot.docs
          .map((doc) => CafeModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch cafes: $e';
    }
  }

  Stream<List<CafeModel>> getCafesStream() {
    return _firestore.collection('cafes').orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => CafeModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<CafeModel?> getCafe(String cafeId) async {
    try {
      final doc = await _firestore.collection('cafes').doc(cafeId).get();
      if (doc.exists) return CafeModel.fromMap(doc.data()!, doc.id);
      return null;
    } catch (e) {
      throw 'Failed to fetch cafe: $e';
    }
  }

  Future<String> addCafe(CafeModel cafe) async {
    try {
      final docRef = await _firestore.collection('cafes').add(cafe.toMap());
      await docRef.update({'id': docRef.id});

      // Auto-seed default tables for the newly added cafe
      final tables = [
        {'tableNumber': 1, 'capacity': 2},
        {'tableNumber': 2, 'capacity': 2},
        {'tableNumber': 3, 'capacity': 4},
        {'tableNumber': 4, 'capacity': 4},
        {'tableNumber': 5, 'capacity': 6},
        {'tableNumber': 6, 'capacity': 8},
      ];
      final batch = _firestore.batch();
      for (var t in tables) {
        final tableDocRef = docRef.collection('tables').doc();
        batch.set(tableDocRef, {
          'tableNumber': t['tableNumber'],
          'capacity': t['capacity'],
          'isActive': true,
        });
      }
      await batch.commit();

      return docRef.id;
    } catch (e) {
      throw 'Failed to add cafe: $e';
    }
  }

  Future<void> deleteCafe(String cafeId) async {
    try {
      await _firestore.collection('cafes').doc(cafeId).delete();
    } catch (e) {
      throw 'Failed to delete cafe: $e';
    }
  }

  Future<void> updateCafe(String cafeId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('cafes').doc(cafeId).update(data);
    } catch (e) {
      throw 'Failed to update cafe: $e';
    }
  }

  /// Toggle a café's active/blocked status (Super Admin)
  Future<void> setCafeActiveStatus(String cafeId, bool isActive) async {
    try {
      await _firestore.collection('cafes').doc(cafeId).update({'isActive': isActive});
    } catch (e) {
      throw 'Failed to update cafe status: $e';
    }
  }

  /// Assign an owner to a café (Super Admin)
  Future<void> assignCafeOwner(String cafeId, String ownerId) async {
    try {
      // Update café document
      await _firestore.collection('cafes').doc(cafeId).update({'ownerId': ownerId});
      // Update user document with cafeId and promote to admin
      await _firestore.collection('users').doc(ownerId).update({
        'cafeId': cafeId,
        'role': 'admin',
      });
    } catch (e) {
      throw 'Failed to assign cafe owner: $e';
    }
  }

  /// Create a new admin user account directly (Super Admin)
  Future<void> createAdminUser({
    required String name,
    required String email,
    required String password,
    required String cafeId,
  }) async {
    final String tempAppName = 'temp_admin_creator_${DateTime.now().millisecondsSinceEpoch}';
    FirebaseApp? tempApp;
    try {
      tempApp = await Firebase.initializeApp(
        name: tempAppName,
        options: Firebase.app().options,
      );

      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      final UserCredential creds = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String newUid = creds.user!.uid;

      // Save user profile in primary Firestore instance
      final UserModel newUser = UserModel(
        uid: newUid,
        name: name,
        email: email,
        role: 'admin',
        createdAt: DateTime.now(),
        cafeId: cafeId,
      );

      await _firestore.collection('users').doc(newUid).set(newUser.toMap());

      // Assign as owner of the café
      await _firestore.collection('cafes').doc(cafeId).update({'ownerId': newUid});
    } on FirebaseAuthException catch (e) {
      throw 'Authentication error: ${e.message}';
    } catch (e) {
      throw 'Failed to create admin user: $e';
    } finally {
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }

  // ============ PRODUCTS ============

  /// Get all products (Super Admin)
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch products: $e';
    }
  }

  /// Get products for a specific café (Café Admin)
  Future<List<ProductModel>> getProductsByCafe(String cafeId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('cafeId', isEqualTo: cafeId)
          .get();
      final list = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      throw 'Failed to fetch products: $e';
    }
  }

  /// Stream products for a specific café
  Stream<List<ProductModel>> getProductsByCafeStream(String cafeId) {
    return _firestore
        .collection('products')
        .where('cafeId', isEqualTo: cafeId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Stream all products (Super Admin)
  Stream<List<ProductModel>> getProductsStream() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<ProductModel?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) return ProductModel.fromMap(doc.data()!, doc.id);
      return null;
    } catch (e) {
      throw 'Failed to fetch product: $e';
    }
  }

  Future<String> addProduct(ProductModel product) async {
    try {
      final docRef = await _firestore.collection('products').add({
        'name': product.name,
        'price': product.price,
        'category': product.category,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'rating': product.rating,
        'reviewCount': product.reviewCount,
        'available': product.available,
        'cafeId': product.cafeId,
        'createdAt': product.createdAt.toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).update({
        'name': product.name,
        'price': product.price,
        'category': product.category,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'rating': product.rating,
        'reviewCount': product.reviewCount,
        'available': product.available,
        'cafeId': product.cafeId,
      });
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }

  Future<List<String>> getCategories({String? cafeId}) async {
    try {
      Query query = _firestore.collection('products');
      if (cafeId != null) {
        query = query.where('cafeId', isEqualTo: cafeId);
      }
      final snapshot = await query.get();
      final Set<String> categories = {};
      for (var doc in snapshot.docs) {
        final category = (doc.data() as Map<String, dynamic>)['category'] ?? '';
        if ((category as String).isNotEmpty) categories.add(category);
      }
      return categories.toList()..sort();
    } catch (e) {
      throw 'Failed to fetch categories: $e';
    }
  }

  // ============ ORDERS ============

  /// Get all orders (Super Admin)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw 'Failed to fetch orders: $e';
    }
  }

  /// Stream all orders (Super Admin)
  Stream<List<OrderModel>> getAllOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList());
  }

  /// Get orders for a specific café (Café Admin)
  Future<List<OrderModel>> getOrdersByCafe(String cafeId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('cafeId', isEqualTo: cafeId)
          .get();
      final list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      throw 'Failed to fetch orders: $e';
    }
  }

  /// Stream orders for a specific café
  Stream<List<OrderModel>> getOrdersByCafeStream(String cafeId) {
    return _firestore
        .collection('orders')
        .where('cafeId', isEqualTo: cafeId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _firestore.collection('orders').add({
        'userId': order.userId,
        'cafeId': order.cafeId ?? '',
        'items': order.items.map((item) => item.toMap()).toList(),
        'total': order.total,
        'status': order.status,
        'createdAt': FieldValue.serverTimestamp(),
        'specialNotes': order.specialNotes,
      });
      return docRef.id;
    } catch (e) {
      throw 'Failed to create order: $e';
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final Map<String, dynamic> updateData = {'status': status};
      if (status == 'Delivered') {
        updateData['deliveredAt'] = DateTime.now().toIso8601String();
      }
      await _firestore.collection('orders').doc(orderId).update(updateData);
    } catch (e) {
      throw 'Failed to update order: $e';
    }
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      throw 'Failed to fetch orders: $e';
    }
  }

  // ============ RESERVATIONS ============

  /// Get reservations for a specific café
  Future<List<ReservationModel>> getReservationsByCafe(String cafeId) async {
    try {
      final snapshot = await _firestore
          .collection('reservations')
          .where('cafeId', isEqualTo: cafeId)
          .get();
      final list = snapshot.docs
          .map((doc) => ReservationModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.reservationDate.compareTo(a.reservationDate));
      return list;
    } catch (e) {
      throw 'Failed to fetch reservations: $e';
    }
  }

  /// Stream reservations for a specific café
  Stream<List<ReservationModel>> getReservationsByCafeStream(String cafeId) {
    return _firestore
        .collection('reservations')
        .where('cafeId', isEqualTo: cafeId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ReservationModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.reservationDate.compareTo(a.reservationDate));
          return list;
        });
  }

  /// Get all reservations (Super Admin)
  Future<List<ReservationModel>> getAllReservations() async {
    try {
      final snapshot = await _firestore
          .collection('reservations')
          .get();
      final list = snapshot.docs
          .map((doc) => ReservationModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.reservationDate.compareTo(a.reservationDate));
      return list;
    } catch (e) {
      throw 'Failed to fetch reservations: $e';
    }
  }

  /// Stream all reservations (Super Admin)
  Stream<List<ReservationModel>> getAllReservationsStream() {
    return _firestore
        .collection('reservations')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ReservationModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.reservationDate.compareTo(a.reservationDate));
          return list;
        });
  }

  Future<void> updateReservationStatus(String reservationId, String status) async {
    try {
      await _firestore
          .collection('reservations')
          .doc(reservationId)
          .update({'status': status});
    } catch (e) {
      throw 'Failed to update reservation: $e';
    }
  }

  // ============ USERS ============

  /// Get all users (Super Admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw 'Failed to fetch users: $e';
    }
  }

  /// Get all admin users (role == 'admin')
  Future<List<UserModel>> getAdminUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw 'Failed to fetch admin users: $e';
    }
  }

  // ============ PLATFORM ANALYTICS (Super Admin) ============

  Future<Map<String, dynamic>> getPlatformAnalytics() async {
    try {
      final results = await Future.wait([
        _firestore.collection('cafes').get(),
        _firestore.collection('orders').get(),
        _firestore.collection('users').get(),
        _firestore.collection('reservations').get(),
        _firestore.collection('products').get(),
      ]);

      final cafesSnap = results[0];
      final ordersSnap = results[1];
      final usersSnap = results[2];
      final reservationsSnap = results[3];
      final productsSnap = results[4];

      final activeCafes = cafesSnap.docs.where((d) => d['isActive'] == true).length;
      final pendingOrders = ordersSnap.docs.where((d) => d['status'] == 'Pending').length;
      final deliveredOrders = ordersSnap.docs.where((d) => d['status'] == 'Delivered').length;
      final customers = usersSnap.docs.where((d) => d['role'] == 'customer').length;
      final pendingReservations =
          reservationsSnap.docs.where((d) => d['status'] == 'pending').length;

      // Revenue calculation
      double totalRevenue = 0;
      for (var doc in ordersSnap.docs) {
        final data = doc.data();
        if (data['status'] == 'Delivered') {
          totalRevenue += (data['total'] as num?)?.toDouble() ?? 0.0;
        }
      }

      return {
        'totalCafes': cafesSnap.size,
        'activeCafes': activeCafes,
        'totalOrders': ordersSnap.size,
        'pendingOrders': pendingOrders,
        'deliveredOrders': deliveredOrders,
        'totalUsers': usersSnap.size,
        'totalCustomers': customers,
        'totalProducts': productsSnap.size,
        'totalReservations': reservationsSnap.size,
        'pendingReservations': pendingReservations,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw 'Failed to fetch analytics: $e';
    }
  }
}
