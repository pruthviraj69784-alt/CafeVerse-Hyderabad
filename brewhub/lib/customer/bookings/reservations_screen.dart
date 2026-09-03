import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/reservation_provider.dart';

const _primaryBrown = Color(0xFF452B19);
const _lightBrown   = Color(0xFF6F4E37);
const _cream        = Color(0xFFF7F3EE);
const _paleGold     = Color(0xFFF5E6D3);
const _textDark     = Color(0xFF2B1A0F);
const _textMid      = Color(0xFF8D6E63);

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<ReservationProvider>().loadUserReservations(authProvider.currentUser!.uid);
      }
    });
  }

  void _confirmCancellation(String reservationId) {
    final authProvider = context.read<AuthProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text('Cancel Reservation?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to cancel this table booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, keep it', style: TextStyle(color: _textMid)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ReservationProvider>().cancelReservation(
                    reservationId,
                    authProvider.currentUser!.uid,
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reservation cancelled successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.currentUser == null) {
      return Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          title: const Text('My Bookings', style: TextStyle(color: _textDark, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: _paleGold,
                child: const Icon(Icons.table_bar_rounded, size: 40, color: _lightBrown),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please login to view reservations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(color: _textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: _primaryBrown));
          }

          final bookings = provider.userReservations;
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _paleGold,
                    child: const Icon(Icons.event_busy_rounded, size: 40, color: _lightBrown),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No bookings found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your reserved café tables will show up here.',
                    style: TextStyle(fontSize: 13, color: _textMid),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadUserReservations(authProvider.currentUser!.uid),
            color: _primaryBrown,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final isConfirmed = booking.status == 'confirmed';
                final isCancelled = booking.status == 'cancelled';

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x04000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cafe Name & Status Badge Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.cafeName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textDark),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isConfirmed
                                    ? const Color(0xFFE8F5E9)
                                    : isCancelled
                                        ? const Color(0xFFECEFF1)
                                        : const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isConfirmed
                                        ? Icons.check_circle_rounded
                                        : isCancelled
                                            ? Icons.cancel_rounded
                                            : Icons.access_time_filled_rounded,
                                    color: isConfirmed
                                        ? Colors.green
                                        : isCancelled
                                            ? Colors.grey
                                            : Colors.orange,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    booking.status.toUpperCase(),
                                    style: TextStyle(
                                      color: isConfirmed
                                          ? Colors.green
                                          : isCancelled
                                              ? Colors.grey
                                              : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Booking Details
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: _textMid),
                            const SizedBox(width: 6),
                            Text(
                              booking.date,
                              style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 15),
                            const Icon(Icons.access_time_rounded, size: 14, color: _textMid),
                            const SizedBox(width: 6),
                            Text(
                              booking.timeSlot,
                              style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.people_alt_rounded, size: 14, color: _textMid),
                            const SizedBox(width: 6),
                            Text(
                              '${booking.guests} Guests',
                              style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 15),
                            const Icon(Icons.table_restaurant_rounded, size: 14, color: _textMid),
                            const SizedBox(width: 6),
                            Text(
                              'Table #${booking.tableNumber}',
                              style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),

                        // Cancel Button
                        if (isConfirmed) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _confirmCancellation(booking.id),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red, width: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text(
                                'Cancel Reservation',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
