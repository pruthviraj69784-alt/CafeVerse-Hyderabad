import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/cafe_model.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/reservation_provider.dart';

const _primaryBrown = Color(0xFF452B19);
const _lightBrown   = Color(0xFF6F4E37);
const _cream        = Color(0xFFF7F3EE);
const _paleGold     = Color(0xFFF5E6D3);
const _goldAccent   = Color(0xFFD4A843);
const _textDark     = Color(0xFF2B1A0F);
const _textMid      = Color(0xFF8D6E63);

class TableBookingScreen extends StatefulWidget {
  final CafeModel cafe;

  const TableBookingScreen({super.key, required this.cafe});

  @override
  State<TableBookingScreen> createState() => _TableBookingScreenState();
}

class _TableBookingScreenState extends State<TableBookingScreen> {
  final List<String> _timeSlots = [
    '11:00 AM',
    '1:00 PM',
    '3:00 PM',
    '5:00 PM',
    '7:00 PM',
    '9:00 PM',
  ];

  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReservationProvider>();
      provider.setSelectedDate(_selectedDay!);
      provider.setSelectedTimeSlot('7:00 PM');
      provider.setSelectedGuests(2);
      provider.checkAvailability(widget.cafe.id);
    });
  }

  void _recheckAvailability() {
    context.read<ReservationProvider>().checkAvailability(widget.cafe.id);
  }

  Future<void> _submitBooking() async {
    final resProvider = context.read<ReservationProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to complete your table reservation.')),
      );
      return;
    }

    final success = await resProvider.bookTable(
      cafeId: widget.cafe.id,
      cafeName: widget.cafe.name,
      userId: authProvider.currentUser!.uid,
      userName: authProvider.currentUser!.name,
      userPhone: authProvider.currentUser!.phone,
    );

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Booking Confirmed!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your table at ${widget.cafe.name} is successfully reserved.', style: const TextStyle(color: _textDark)),
              const SizedBox(height: 12),
              Text('Date: ${resProvider.selectedDate.day}/${resProvider.selectedDate.month}/${resProvider.selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Time Slot: ${resProvider.selectedTimeSlot}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Guests: ${resProvider.selectedGuests}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // pop modal
                Navigator.pop(context); // pop booking page
              },
              child: const Text('Great, thanks!', style: TextStyle(color: _primaryBrown, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else if (resProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${resProvider.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: const Text(
          'Book a Table',
          style: TextStyle(color: _textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Café Header
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.cafe.imageUrl.trim().isEmpty
                              ? 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=500&q=80'
                              : widget.cafe.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, err, stack) => const Icon(Icons.coffee),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.cafe.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textDark),
                            ),
                            Text(
                              '📍 ${widget.cafe.area}',
                              style: const TextStyle(fontSize: 12, color: _textMid),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Calendar Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textDark)),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 30)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      provider.setSelectedDate(selectedDay);
                      _recheckAvailability();
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(color: _lightBrown, shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: _primaryBrown, shape: BoxShape.circle),
                      markerDecoration: BoxDecoration(color: _goldAccent, shape: BoxShape.circle),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        color: _paleGold,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      formatButtonTextStyle: TextStyle(color: _primaryBrown, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Guests selection
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Number of Guests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textDark)),
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final guestNum = index + 1;
                      final isSelected = provider.selectedGuests == guestNum;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text('$guestNum Guest${guestNum > 1 ? 's' : ''}'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              provider.setSelectedGuests(guestNum);
                              _recheckAvailability();
                            }
                          },
                          selectedColor: _primaryBrown,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : _textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Time Slots grid
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Select Time Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textDark)),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _timeSlots[index];
                      final isSelected = provider.selectedTimeSlot == slot;
                      return GestureDetector(
                        onTap: () {
                          provider.setSelectedTimeSlot(slot);
                          _recheckAvailability();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryBrown : _cream,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? _primaryBrown : Colors.grey.shade200,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              slot,
                              style: TextStyle(
                                color: isSelected ? Colors.white : _textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Live Availability Indicator
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: provider.availableTables.isNotEmpty
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: provider.availableTables.isNotEmpty
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          provider.availableTables.isNotEmpty
                              ? Icons.check_circle_outline_rounded
                              : Icons.error_outline_rounded,
                          color: provider.availableTables.isNotEmpty ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.availableTables.isNotEmpty
                              ? '${provider.availableTables.length} table(s) available for selection.'
                              : 'No tables available for this group size/slot.',
                          style: TextStyle(
                            color: provider.availableTables.isNotEmpty ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Confirm Reservation Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.availableTables.isNotEmpty && !provider.isLoading
                          ? _submitBooking
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBrown,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Confirm Booking',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
