import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }
}

class OrderModel {
  final String orderId;
  final String userId;
  final String cafeId;          // ← required so admin panel can filter
  final List<OrderItemModel> items;
  final double total;
  final String status; // Pending, Preparing, Ready, Delivered
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? specialNotes;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.cafeId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    this.specialNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'cafeId': cafeId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'specialNotes': specialNotes,
    };
  }

  factory OrderModel.fromMap(Object? map, String docId) {
    final data = map as Map<String, dynamic>;
    return OrderModel(
      orderId: docId,
      userId: data['userId'] ?? '',
      cafeId: data['cafeId'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: (data['total'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Pending',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : DateTime.now(),
      deliveredAt: data['deliveredAt'] is Timestamp
          ? (data['deliveredAt'] as Timestamp).toDate()
          : data['deliveredAt'] != null
              ? DateTime.parse(data['deliveredAt'] as String)
              : null,
      specialNotes: data['specialNotes'],
    );
  }

  OrderModel copyWith({
    String? orderId,
    String? userId,
    String? cafeId,
    List<OrderItemModel>? items,
    double? total,
    String? status,
    DateTime? createdAt,
    DateTime? deliveredAt,
    String? specialNotes,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      cafeId: cafeId ?? this.cafeId,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      specialNotes: specialNotes ?? this.specialNotes,
    );
  }
}
