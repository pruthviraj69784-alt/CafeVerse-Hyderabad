import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ PRODUCTS ============

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('products').orderBy('createdAt', descending: true).get();
      return snapshot.docs
          .map((doc) =>
              ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch products: $e';
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch products: $e';
    }
  }

  // Stream all products
  Stream<List<ProductModel>> getProductsStream() {
    return _firestore.collection('products').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get single product
  Future<ProductModel?> getProduct(String productId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch product: $e';
    }
  }

  // Add product (Admin)
  Future<String> addProduct(ProductModel product) async {
    try {
      DocumentReference docRef = await _firestore.collection('products').add({
        'name': product.name,
        'price': product.price,
        'category': product.category,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'rating': product.rating,
        'reviewCount': product.reviewCount,
        'available': product.available,
        'createdAt': product.createdAt.toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }

  // Update product (Admin)
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
      });
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  // Delete product (Admin)
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }

  // ============ ORDERS ============

  // Create order
  Future<String> createOrder(OrderModel order, String cafeId) async {
    try {
      DocumentReference docRef = await _firestore.collection('orders').add({
        'userId': order.userId,
        'cafeId': cafeId,
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

  // Get user orders
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      throw 'Failed to fetch orders: $e';
    }
  }

  // Stream user orders
  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  // Get all orders (Admin)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('orders').orderBy('createdAt', descending: true).get();
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch orders: $e';
    }
  }

  // Stream all orders (Admin)
  Stream<List<OrderModel>> getAllOrdersStream() {
    return _firestore.collection('orders').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Update order status (Admin)
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      Map<String, dynamic> updateData = {'status': status};
      if (status == 'Delivered') {
        updateData['deliveredAt'] = DateTime.now().toIso8601String();
      }
      await _firestore.collection('orders').doc(orderId).update(updateData);
    } catch (e) {
      throw 'Failed to update order: $e';
    }
  }

  // Get single order
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch order: $e';
    }
  }

  // Stream single order for real-time updates
  Stream<OrderModel?> getOrderStream(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((doc) {
      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // Get categories
  Future<List<String>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      Set<String> categories = {};
      for (var doc in snapshot.docs) {
        String category = doc['category'] ?? '';
        if (category.isNotEmpty) {
          categories.add(category);
        }
      }
      return categories.toList()..sort();
    } catch (e) {
      throw 'Failed to fetch categories: $e';
    }
  }
}
