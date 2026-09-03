class ReservationModel {
  final String id;
  final String cafeId;
  final String cafeName;
  final String userId;
  final String userName;
  final String tableId;
  final int tableNumber;
  final String date; // Format: YYYY-MM-DD
  final String timeSlot;
  final int guests;
  final String status; // pending, confirmed, cancelled
  final DateTime createdAt;

  ReservationModel({
    required this.id,
    required this.cafeId,
    required this.cafeName,
    required this.userId,
    required this.userName,
    required this.tableId,
    required this.tableNumber,
    required this.date,
    required this.timeSlot,
    required this.guests,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'cafeId': cafeId,
      'cafeName': cafeName,
      'userId': userId,
      'userName': userName,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'date': date,
      'timeSlot': timeSlot,
      'guests': guests,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReservationModel.fromMap(Map<String, dynamic> data, String id) {
    return ReservationModel(
      id: id,
      cafeId: data['cafeId'] ?? '',
      cafeName: data['cafeName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Customer',
      tableId: data['tableId'] ?? '',
      tableNumber: data['tableNumber'] ?? 0,
      date: data['date'] ?? '',
      timeSlot: data['timeSlot'] ?? '',
      guests: data['guests'] ?? 2,
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }
}
