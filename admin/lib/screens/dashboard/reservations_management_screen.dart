import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/admin_reservation_provider.dart';
import '../../services/providers/auth_provider.dart';
import '../../models/reservation_model.dart';

class ReservationsManagementScreen extends StatefulWidget {
  const ReservationsManagementScreen({super.key});

  @override
  State<ReservationsManagementScreen> createState() =>
      _ReservationsManagementScreenState();
}

class _ReservationsManagementScreenState
    extends State<ReservationsManagementScreen> {
  static const _filters = ['all', 'pending', 'confirmed', 'cancelled', 'completed'];
  static const _filterLabels = ['All', 'Pending', 'Confirmed', 'Cancelled', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminReservationProvider>();

    return Column(
      children: [
        // ── Filter Chips ───────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filters.length, (i) {
                final isSelected = provider.filterStatus == _filters[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => provider.setFilter(_filters[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF3B2010) : const Color(0xFFF5F0E8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _filterLabels[i],
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF3B2010),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        // ── Stats Row ─────────────────────────────────────────────
        Container(
          color: const Color(0xFFF7F3EE),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _StatChip(
                label: 'Pending',
                value: provider.pendingCount.toString(),
                color: const Color(0xFFBF360C),
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Today',
                value: provider.todayCount.toString(),
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Confirmed',
                value: provider.confirmedCount.toString(),
                color: const Color(0xFF2E7D32),
              ),
            ],
          ),
        ),
        // ── List ──────────────────────────────────────────────────
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.filteredReservations.isEmpty
                  ? _emptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        final auth = context.read<AuthProvider>();
                        final cafeId = auth.currentUser?.cafeId;
                        if (cafeId != null && cafeId.isNotEmpty) {
                          await context.read<AdminReservationProvider>().loadReservationsForCafe(cafeId);
                        } else {
                          await context.read<AdminReservationProvider>().loadAllReservations();
                        }
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filteredReservations.length,
                        itemBuilder: (context, index) {
                          return _ReservationCard(
                            reservation: provider.filteredReservations[index],
                            onStatusChange: (status) async {
                              final res = provider.filteredReservations[index];
                              await provider.updateStatus(res.id, status);
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_seat_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No reservations found',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color.withAlpha(180), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final Future<void> Function(String status) onStatusChange;

  const _ReservationCard({required this.reservation, required this.onStatusChange});

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFBF360C);
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.pending_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'completed':
        return Icons.done_all_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(reservation.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(10),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_statusIcon(reservation.status), color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        reservation.userPhone,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withAlpha(18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reservation.status[0].toUpperCase() + reservation.status.substring(1),
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: _formatDate(reservation.reservationDate)),
                const SizedBox(height: 8),
                _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    value: reservation.timeSlot),
                const SizedBox(height: 8),
                _DetailRow(
                    icon: Icons.people_rounded,
                    label: 'Guests',
                    value: '${reservation.guestCount} guests · Table #${reservation.tableNumber}'),
                if (reservation.specialRequests?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  _DetailRow(
                      icon: Icons.note_rounded,
                      label: 'Note',
                      value: reservation.specialRequests!),
                ],
              ],
            ),
          ),
          // Action Buttons (only for pending)
          if (reservation.status == 'pending')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onStatusChange('cancelled'),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFBF360C),
                        side: const BorderSide(color: Color(0xFFBF360C)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onStatusChange('confirmed'),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Mark as completed (for confirmed)
          if (reservation.status == 'confirmed')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => onStatusChange('completed'),
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: const Text('Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6F4E37)),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
