/// Unified CafeModel that reads documents written by both:
/// • The old seed service (fields: area, costForTwo, latitude, longitude, ambianceTags, photoUrls)
/// • The admin app (fields: address, city, lat, lng, tags, isActive, isApproved, ownerId)
class CafeModel {
  final String id;
  final String name;

  // Location — admin writes 'address'+'city', seed writes 'area'
  final String area;      // mapped from 'area' OR 'city' OR 'address'
  final String address;   // mapped from 'address' (admin) OR 'area' (seed)

  final String imageUrl;
  final double rating;
  final int costForTwo;   // admin may not set this; defaults to 0
  final String description;

  // Coordinates — admin writes 'lat'/'lng', seed writes 'latitude'/'longitude'
  final double latitude;
  final double longitude;

  final List<String> photoUrls;
  final List<String> ambianceTags; // mapped from 'ambianceTags' OR 'tags'

  // Admin-only metadata (ignored by customer views but preserved)
  final bool isActive;
  final bool isApproved;
  final String? ownerId;

  CafeModel({
    required this.id,
    required this.name,
    required this.area,
    String? address, // optional — defaults to area value
    required this.imageUrl,
    required this.rating,
    required this.costForTwo,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.photoUrls,
    required this.ambianceTags,
    this.isActive = true,
    this.isApproved = true,
    this.ownerId,
  }) : address = address ?? area;

  factory CafeModel.fromMap(Map<String, dynamic> data, String id) {
    // ── Coordinates ────────────────────────────────────────────────
    // Admin app stores 'lat'/'lng'; seed service stores 'latitude'/'longitude'
    final double lat = (data['lat'] as num?)?.toDouble() ??
        (data['latitude'] as num?)?.toDouble() ??
        17.4065; // Hyderabad center default

    final double lng = (data['lng'] as num?)?.toDouble() ??
        (data['longitude'] as num?)?.toDouble() ??
        78.4772;

    // ── Location label ─────────────────────────────────────────────
    // Admin writes city/address; seed writes area
    final String areaStr = (data['area'] as String?)?.isNotEmpty == true
        ? data['area'] as String
        : (data['city'] as String?)?.isNotEmpty == true
            ? data['city'] as String
            : (data['address'] as String?) ?? '';

    final String addressStr = (data['address'] as String?)?.isNotEmpty == true
        ? data['address'] as String
        : areaStr;

    // ── Ambiance / Tags ────────────────────────────────────────────
    final List<String> tags =
        (data['ambianceTags'] != null && (data['ambianceTags'] as List).isNotEmpty)
            ? List<String>.from(data['ambianceTags'] as List)
            : List<String>.from(data['tags'] ?? []);

    // ── Photo URLs ─────────────────────────────────────────────────
    final List<String> photos = List<String>.from(data['photoUrls'] ?? []);
    final String imgUrl = (data['imageUrl'] as String?) ?? '';
    // Ensure imageUrl appears in the photos list for carousel
    if (imgUrl.isNotEmpty && !photos.contains(imgUrl)) {
      photos.insert(0, imgUrl);
    }

    return CafeModel(
      id: id,
      name: (data['name'] as String?) ?? '',
      area: areaStr,
      address: addressStr,
      imageUrl: imgUrl,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      costForTwo: (data['costForTwo'] as num?)?.toInt() ?? 0,
      description: (data['description'] as String?) ?? '',
      latitude: lat,
      longitude: lng,
      photoUrls: photos,
      ambianceTags: tags,
      isActive: (data['isActive'] as bool?) ?? true,
      isApproved: (data['isApproved'] as bool?) ?? true,
      ownerId: data['ownerId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'area': area,
      'address': address,
      'imageUrl': imageUrl,
      'rating': rating,
      'costForTwo': costForTwo,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'lat': latitude,
      'lng': longitude,
      'photoUrls': photoUrls,
      'ambianceTags': ambianceTags,
      'tags': ambianceTags,
      'isActive': isActive,
      'isApproved': isApproved,
      'ownerId': ownerId,
    };
  }
}
