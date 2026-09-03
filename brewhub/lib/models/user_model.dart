class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'customer' or 'admin' or 'superadmin'
  final String? phone;
  final String? address;
  final DateTime createdAt;
  final String? cafeId; // Associated cafe for admin users

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    required this.createdAt,
    this.cafeId,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'cafeId': cafeId,
    };
  }

  // Create from Map/Firebase
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];
    DateTime createdAt;

    if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else if (createdAtValue != null) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(
        createdAtValue is int ? createdAtValue : createdAtValue.toString().isNotEmpty ? int.tryParse(createdAtValue.toString()) ?? DateTime.now().millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      createdAt = DateTime.now();
    }

    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      phone: map['phone'],
      address: map['address'],
      createdAt: createdAt,
      cafeId: map['cafeId'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? address,
    DateTime? createdAt,
    String? cafeId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      cafeId: cafeId ?? this.cafeId,
    );
  }
}
