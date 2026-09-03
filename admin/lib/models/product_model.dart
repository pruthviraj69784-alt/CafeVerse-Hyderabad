class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool available;
  final DateTime createdAt;
  final String? cafeId; // Multi-tenant: which café this product belongs to

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.available = true,
    required this.createdAt,
    this.cafeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'available': available,
      'createdAt': createdAt.toIso8601String(),
      'cafeId': cafeId,
    };
  }

  factory ProductModel.fromMap(Object? map, String docId) {
    final data = map as Map<String, dynamic>;
    return ProductModel(
      id: docId,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      available: data['available'] ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      cafeId: data['cafeId'],
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    String? description,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    bool? available,
    DateTime? createdAt,
    String? cafeId,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      available: available ?? this.available,
      createdAt: createdAt ?? this.createdAt,
      cafeId: cafeId ?? this.cafeId,
    );
  }
}
