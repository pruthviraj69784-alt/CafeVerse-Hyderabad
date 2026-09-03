import 'package:flutter_test/flutter_test.dart';
import 'package:brewhub/models/table_model.dart';
import 'package:brewhub/models/reservation_model.dart';

void main() {
  group('Table and Reservation Model Tests', () {
    test('TableModel serialization & deserialization', () {
      final table = TableModel(
        id: 'table_1',
        tableNumber: 3,
        capacity: 4,
        isActive: true,
      );

      final map = table.toMap();
      expect(map['tableNumber'], 3);
      expect(map['capacity'], 4);
      expect(map['isActive'], true);

      final deserialized = TableModel.fromMap(map, 'table_1');
      expect(deserialized.id, 'table_1');
      expect(deserialized.tableNumber, 3);
      expect(deserialized.capacity, 4);
      expect(deserialized.isActive, true);
    });

    test('ReservationModel serialization & deserialization', () {
      final now = DateTime.now();
      final reservation = ReservationModel(
        id: 'booking_123',
        cafeId: 'cafe_abc',
        cafeName: 'Autumn Leaf Cafe',
        userId: 'user_xyz',
        userName: 'John Doe',
        tableId: 'table_1',
        tableNumber: 3,
        date: '2026-06-07',
        timeSlot: '7:00 PM',
        guests: 4,
        status: 'confirmed',
        createdAt: now,
      );

      final map = reservation.toMap();
      expect(map['cafeId'], 'cafe_abc');
      expect(map['cafeName'], 'Autumn Leaf Cafe');
      expect(map['userId'], 'user_xyz');
      expect(map['userName'], 'John Doe');
      expect(map['tableId'], 'table_1');
      expect(map['tableNumber'], 3);
      expect(map['date'], '2026-06-07');
      expect(map['timeSlot'], '7:00 PM');
      expect(map['guests'], 4);
      expect(map['status'], 'confirmed');
      expect(map['createdAt'], now.toIso8601String());

      final deserialized = ReservationModel.fromMap(map, 'booking_123');
      expect(deserialized.id, 'booking_123');
      expect(deserialized.cafeId, 'cafe_abc');
      expect(deserialized.cafeName, 'Autumn Leaf Cafe');
      expect(deserialized.userId, 'user_xyz');
      expect(deserialized.userName, 'John Doe');
      expect(deserialized.tableId, 'table_1');
      expect(deserialized.tableNumber, 3);
      expect(deserialized.date, '2026-06-07');
      expect(deserialized.timeSlot, '7:00 PM');
      expect(deserialized.guests, 4);
      expect(deserialized.status, 'confirmed');
      // Truncate milliseconds/microseconds differences from serialization parse
      expect(deserialized.createdAt.year, now.year);
      expect(deserialized.createdAt.month, now.month);
      expect(deserialized.createdAt.day, now.day);
      expect(deserialized.createdAt.hour, now.hour);
      expect(deserialized.createdAt.minute, now.minute);
    });
  });
}
