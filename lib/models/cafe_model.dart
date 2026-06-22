class CafeModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final Map<String, String> openingHours; // e.g. {'Mon': '8am-10pm'}
  final bool isActive;
  final bool isApproved;
  final String? ownerId; // uid of admin user managing this café
  final DateTime createdAt;
  final double? lat;
  final double? lng;

  CafeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.tags = const [],
    this.openingHours = const {},
    this.isActive = true,
    this.isApproved = true,
    this.ownerId,
    required this.createdAt,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
      'openingHours': openingHours,
      'isActive': isActive,
      'isApproved': isApproved,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'lat': lat,
      'lng': lng,
    };
  }

  factory CafeModel.fromMap(Map<String, dynamic> data, String docId) {
    return CafeModel(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? 'Hyderabad',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      openingHours: Map<String, String>.from(data['openingHours'] ?? {}),
      isActive: data['isActive'] ?? true,
      isApproved: data['isApproved'] ?? true,
      ownerId: data['ownerId'],
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
    );
  }

  CafeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    List<String>? tags,
    Map<String, String>? openingHours,
    bool? isActive,
    bool? isApproved,
    String? ownerId,
    DateTime? createdAt,
    double? lat,
    double? lng,
  }) {
    return CafeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      tags: tags ?? this.tags,
      openingHours: openingHours ?? this.openingHours,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
