import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/table_model.dart';
import '../models/reservation_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all tables for a cafe
  Future<List<TableModel>> getCafeTables(String cafeId) async {
    try {
      final snapshot = await _firestore
          .collection('cafes')
          .doc(cafeId)
          .collection('tables')
          .get();
      return snapshot.docs
          .map((doc) => TableModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch tables: $e';
    }
  }

  // Get available tables for a cafe, date, slot, and guest count
  Future<List<TableModel>> getAvailableTables(
      String cafeId, String date, String timeSlot, int guests) async {
    try {
      // 1. Get all tables
      List<TableModel> allTables = await getCafeTables(cafeId);

      // If no tables exist for this cafe, dynamically seed default tables
      if (allTables.isEmpty) {
        final tables = [
          {'tableNumber': 1, 'capacity': 2},
          {'tableNumber': 2, 'capacity': 2},
          {'tableNumber': 3, 'capacity': 4},
          {'tableNumber': 4, 'capacity': 4},
          {'tableNumber': 5, 'capacity': 6},
          {'tableNumber': 6, 'capacity': 8},
        ];
        final batch = _firestore.batch();
        final cafeRef = _firestore.collection('cafes').doc(cafeId);
        for (var t in tables) {
          final tableDocRef = cafeRef.collection('tables').doc();
          batch.set(tableDocRef, {
            'tableNumber': t['tableNumber'],
            'capacity': t['capacity'],
            'isActive': true,
          });
        }
        await batch.commit();
        // Fetch again after seeding
        allTables = await getCafeTables(cafeId);
      }

      // 2. Query all active bookings for this date and time slot
      final bookingsQuery = await _firestore
          .collection('reservations')
          .where('cafeId', isEqualTo: cafeId)
          .where('date', isEqualTo: date)
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      final bookedTableIds = bookingsQuery.docs
          .map((doc) => doc.data()['tableId'] as String)
          .toSet();

      // 3. Filter tables that have enough capacity and are not booked
      final available = allTables.where((table) {
        final matchesCapacity = table.capacity >= guests;
        final isNotBooked = !bookedTableIds.contains(table.id);
        return table.isActive && matchesCapacity && isNotBooked;
      }).toList();

      // Sort by capacity ascending so we assign the smallest table fitting the group size
      available.sort((a, b) => a.capacity.compareTo(b.capacity));
      return available;
    } catch (e) {
      throw 'Error checking availability: $e';
    }
  }

  // Confirm booking in an atomic transaction
  Future<String> createBooking({
    required String cafeId,
    required String cafeName,
    required String userId,
    required String userName,
    required TableModel table,
    required String date,
    required String timeSlot,
    required int guests,
    String? userPhone,
  }) async {
    // Generate a unique slot-specific key for the reservation to enforce slot isolation and allow transaction.get()
    final slotKey = '${table.id}_${date}_${timeSlot.replaceAll(' ', '_').replaceAll(':', '_')}';
    final reservationRef = _firestore.collection('reservations').doc(slotKey);

    try {
      return await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(reservationRef);

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          final status = data?['status'] ?? 'cancelled';
          if (status == 'confirmed' || status == 'pending') {
            throw 'This table has already been reserved for this slot by someone else. Please try another table or time.';
          }
        }

        // Set the reservation document inside the transaction
        transaction.set(reservationRef, {
          'cafeId': cafeId,
          'cafeName': cafeName,
          'userId': userId,
          'userName': userName,
          'userPhone': userPhone ?? '',
          'tableId': table.id,
          'tableNumber': table.tableNumber,
          'date': date,
          'reservationDate': date, // for admin order-by & parsing
          'timeSlot': timeSlot,
          'guests': guests,
          'guestCount': guests, // for admin parsing
          'status': 'confirmed', // immediately confirm
          'createdAt': DateTime.now().toIso8601String(),
        });

        return reservationRef.id;
      });
    } catch (e) {
      throw 'Booking failed: $e';
    }
  }

  // Fetch user reservations
  Future<List<ReservationModel>> getUserReservations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reservations')
          .where('userId', isEqualTo: userId)
          .get();
      final list = snapshot.docs
          .map((doc) => ReservationModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort: upcoming first, then created date
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      throw 'Failed to load reservations: $e';
    }
  }

  // Cancel reservation
  Future<void> cancelReservation(String reservationId) async {
    try {
      await _firestore
          .collection('reservations')
          .doc(reservationId)
          .update({'status': 'cancelled'});
    } catch (e) {
      throw 'Failed to cancel reservation: $e';
    }
  }
}
