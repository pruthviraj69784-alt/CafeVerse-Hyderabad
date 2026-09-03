class ReservationModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String cafeId;
  final String cafeName;
  final String tableId;
  final int tableNumber;
  final DateTime reservationDate;
  final String timeSlot;
  final int guestCount;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final String? specialRequests;
  final DateTime createdAt;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.cafeId,
    required this.cafeName,
    required this.tableId,
    required this.tableNumber,
    required this.reservationDate,
    required this.timeSlot,
    required this.guestCount,
    required this.status,
    this.specialRequests,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'cafeId': cafeId,
      'cafeName': cafeName,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'reservationDate': reservationDate.toIso8601String(),
      'timeSlot': timeSlot,
      'guestCount': guestCount,
      'status': status,
      'specialRequests': specialRequests,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReservationModel.fromMap(Map<String, dynamic> data, String docId) {
    final rawDate = data['reservationDate'] ?? data['date'];
    final guestsNum = data['guestCount'] ?? data['guests'] ?? 1;

    return ReservationModel(
      id: docId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userPhone: data['userPhone'] ?? '',
      cafeId: data['cafeId'] ?? '',
      cafeName: data['cafeName'] ?? '',
      tableId: data['tableId'] ?? '',
      tableNumber: data['tableNumber'] ?? 0,
      reservationDate: rawDate != null
          ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
          : DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      guestCount: guestsNum is int ? guestsNum : int.tryParse(guestsNum.toString()) ?? 1,
      status: data['status'] ?? 'pending',
      specialRequests: data['specialRequests'],
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  ReservationModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? cafeId,
    String? cafeName,
    String? tableId,
    int? tableNumber,
    DateTime? reservationDate,
    String? timeSlot,
    int? guestCount,
    String? status,
    String? specialRequests,
    DateTime? createdAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      cafeId: cafeId ?? this.cafeId,
      cafeName: cafeName ?? this.cafeName,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      reservationDate: reservationDate ?? this.reservationDate,
      timeSlot: timeSlot ?? this.timeSlot,
      guestCount: guestCount ?? this.guestCount,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
