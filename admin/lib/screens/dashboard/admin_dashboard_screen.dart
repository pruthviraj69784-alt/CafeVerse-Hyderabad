import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/product_provider.dart';
import '../../services/providers/order_provider.dart';
import '../../services/providers/admin_cafe_provider.dart';
import '../../services/providers/admin_reservation_provider.dart';
import '../../models/order_model.dart';
import 'menu_management_screen.dart';
import 'orders_management_screen.dart';
import 'reservations_management_screen.dart';
import 'cafe_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  static const _brown = Color(0xFF3B2010);
  static const _bg = Color(0xFFF7F3EE);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final cafeId = auth.currentUser?.cafeId;

      if (cafeId != null && cafeId.isNotEmpty) {
        context.read<ProductProvider>().loadProductsByCafe(cafeId);
        context.read<OrderProvider>().loadOrdersByCafe(cafeId);
        context.read<AdminReservationProvider>().loadReservationsForCafe(cafeId);
        context.read<AdminCafeProvider>().loadCafeById(cafeId);
      } else {
        context.read<ProductProvider>().loadProducts();
        context.read<OrderProvider>().loadAllOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final cafe = context.watch<AdminCafeProvider>().selectedCafe;

    const tabLabels = ['Dashboard', 'Menu', 'Orders', 'Bookings', 'Café'];

    return Scaffold(
      backgroundColor: _bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: _AdminAppBar(
          title: cafe?.name ?? 'CaféVerse Admin',
          subtitle: tabLabels[_currentIndex],
          onLogout: () => _showLogoutDialog(context),
          userName: user?.name ?? 'Admin',
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(tabLabels),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: _brown),
            SizedBox(width: 10),
            Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to logout from the admin panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(List<String> labels) {
    final items = [
      Icons.dashboard_rounded,
      Icons.restaurant_menu_rounded,
      Icons.shopping_bag_rounded,
      Icons.event_seat_rounded,
      Icons.store_rounded,
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isSelected = _currentIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _brown.withAlpha(20) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[i],
                          color: isSelected ? _brown : Colors.grey.shade400, size: 23),
                      const SizedBox(height: 3),
                      Text(
                        labels[i],
                        style: TextStyle(
                          color: isSelected ? _brown : Colors.grey.shade400,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const _AdminDashboardHome();
      case 1:
        return const AdminMenuManagementScreen();
      case 2:
        return const AdminOrdersManagementScreen();
      case 3:
        return const ReservationsManagementScreen();
      case 4:
        return const CafeProfileScreen();
      default:
        return const _AdminDashboardHome();
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────
class _AdminAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final String userName;
  final VoidCallback onLogout;

  const _AdminAppBar({
    required this.title,
    required this.subtitle,
    required this.userName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C1A0A), Color(0xFF6F4E37)],
        ),
        boxShadow: [
          BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A843).withAlpha(220),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_cafe_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withAlpha(160),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withAlpha(40)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.white, size: 15),
                      SizedBox(width: 5),
                      Text('Logout',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Dashboard Home Tab
// ─────────────────────────────────────────────────────────────────
class _AdminDashboardHome extends StatelessWidget {
  const _AdminDashboardHome();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final cafe = context.watch<AdminCafeProvider>().selectedCafe;
    final products = context.watch<ProductProvider>().products;
    final orders = context.watch<OrderProvider>().orders;
    final reservations = context.watch<AdminReservationProvider>();

    final pendingOrders = orders.where((o) => o.status == 'Pending').length;
    final pendingReservations = reservations.pendingCount;
    final todayReservations = reservations.todayCount;

    // Revenue
    double revenue = 0;
    for (final o in orders) {
      if (o.status == 'Delivered') revenue += o.total;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome Banner ──────────────────────────────────────
          _WelcomeBanner(
            cafeName: cafe?.name ?? 'Your Café',
            userName: user?.name ?? 'Admin',
            imageUrl: cafe?.imageUrl ??
                'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=1200&q=80',
          ),
          const SizedBox(height: 24),

          // ── Revenue Card ─────────────────────────────────────────
          _RevenueCard(revenue: revenue, orderCount: orders.length),
          const SizedBox(height: 24),

          // ── Section header ───────────────────────────────────────
          _SectionHeader(title: 'Today\'s Overview'),
          const SizedBox(height: 14),

          // ── Stats Grid ───────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MiniStatCard(
                icon: Icons.fastfood_rounded,
                label: 'Menu Items',
                value: products.length.toString(),
                color: const Color(0xFF6F4E37),
                imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
              ),
              _MiniStatCard(
                icon: Icons.shopping_bag_rounded,
                label: 'Total Orders',
                value: orders.length.toString(),
                color: const Color(0xFF1565C0),
                imageUrl: 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&w=400&q=80',
              ),
              _MiniStatCard(
                icon: Icons.pending_actions_rounded,
                label: 'Pending Orders',
                value: pendingOrders.toString(),
                color: const Color(0xFFBF360C),
                imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=400&q=80',
              ),
              _MiniStatCard(
                icon: Icons.event_seat_rounded,
                label: "Today's Bookings",
                value: todayReservations.toString(),
                color: const Color(0xFF2E7D32),
                imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Alerts Section ────────────────────────────────────────
          if (pendingOrders > 0 || pendingReservations > 0) ...[
            _SectionHeader(title: 'Action Required'),
            const SizedBox(height: 14),
            if (pendingOrders > 0)
              _AlertCard(
                icon: Icons.shopping_bag_rounded,
                title: '$pendingOrders Pending Orders',
                subtitle: 'Customers are waiting — process them now.',
                color: const Color(0xFFBF360C),
              ),
            if (pendingReservations > 0) ...[
              const SizedBox(height: 10),
              _AlertCard(
                icon: Icons.event_seat_rounded,
                title: '$pendingReservations Reservation Requests',
                subtitle: 'Approve or decline incoming booking requests.',
                color: const Color(0xFF1565C0),
              ),
            ],
            const SizedBox(height: 24),
          ],

          // ── Recent Orders ─────────────────────────────────────────
          _SectionHeader(title: 'Recent Orders'),
          const SizedBox(height: 14),
          if (orders.isEmpty)
            _EmptyState(
              icon: Icons.shopping_bag_outlined,
              message: 'No orders yet for your café.',
            )
          else
            ...orders.take(5).map((order) => _RecentOrderTile(order: order)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Welcome Banner
// ─────────────────────────────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final String cafeName;
  final String userName;
  final String imageUrl;

  const _WelcomeBanner({
    required this.cafeName,
    required this.userName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B2010).withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl.trim().isEmpty
                  ? 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=1200&q=80'
                  : imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, st) => Image.network(
                'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=1200&q=80',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x22000000), Color(0xCC000000)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A843).withAlpha(220),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '☕  Café Admin',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome, $userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cafeName,
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Revenue Card
// ─────────────────────────────────────────────────────────────────
class _RevenueCard extends StatelessWidget {
  final double revenue;
  final int orderCount;

  const _RevenueCard({required this.revenue, required this.orderCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1559526324-593bc073d938?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, err, stack)  => Container(color: const Color(0xFF2E7D32)),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xCC1B5E20), Color(0xDD2E7D32)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: const Icon(Icons.currency_rupee_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '₹${revenue.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Total Revenue · $orderCount orders',
                          style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: const Text(
                      'All Time',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF6F4E37),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B1A0F),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Mini Stat Card  (with image background)
// ─────────────────────────────────────────────────────────────────
class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String imageUrl;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(60),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background photo
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, err, stack)  => Container(color: color),
            ),
            // Colored gradient overlay so text is always legible
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withAlpha(185),
                    color.withAlpha(230),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: Icon(icon, size: 18, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withAlpha(215),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Alert Card
// ─────────────────────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _AlertCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color, fontSize: 13)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color.withAlpha(150)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Recent Order Tile
// ─────────────────────────────────────────────────────────────────
class _RecentOrderTile extends StatelessWidget {
  final OrderModel order;
  const _RecentOrderTile({required this.order});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFBF360C);
      case 'processing':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6F4E37).withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long_rounded, size: 20, color: Color(0xFF6F4E37)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.orderId.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  '${order.items.length} item${order.items.length != 1 ? 's' : ''} · ₹${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor(order.status).withAlpha(18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.status,
              style: TextStyle(
                color: _statusColor(order.status),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
        ],
      ),
    );
  }
}
