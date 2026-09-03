import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/admin_cafe_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/cafe_model.dart';
import '../../models/user_model.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  int _currentIndex = 0;

  static const _navy = Color(0xFF1565C0);
  static const _bg = Color(0xFFF0F4FC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCafeProvider>().loadCafes();
      context.read<AdminCafeProvider>().loadAdminUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    const tabLabels = ['Dashboard', 'Cafés', 'Users', 'Analytics'];

    return Scaffold(
      backgroundColor: _bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: _SuperAppBar(
          subtitle: tabLabels[_currentIndex],
          onLogout: () => _showLogoutDialog(context),
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
            Icon(Icons.logout_rounded, color: _navy),
            SizedBox(width: 10),
            Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
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
      Icons.store_rounded,
      Icons.people_rounded,
      Icons.bar_chart_rounded,
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
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _navy.withAlpha(20) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[i],
                          color: isSelected ? _navy : Colors.grey.shade400, size: 24),
                      const SizedBox(height: 3),
                      Text(
                        labels[i],
                        style: TextStyle(
                          color: isSelected ? _navy : Colors.grey.shade400,
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
        return const _SuperDashboardHome();
      case 1:
        return const _CafeManagementTab();
      case 2:
        return const _UserManagementTab();
      case 3:
        return const _PlatformAnalyticsTab();
      default:
        return const _SuperDashboardHome();
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// Super App Bar
// ─────────────────────────────────────────────────────────────────
class _SuperAppBar extends StatelessWidget {
  final String subtitle;
  final VoidCallback onLogout;

  const _SuperAppBar({required this.subtitle, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
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
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'CaféVerse · Super Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 11),
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
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
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
// Dashboard Home
// ─────────────────────────────────────────────────────────────────
class _SuperDashboardHome extends StatelessWidget {
  const _SuperDashboardHome();

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return FutureBuilder<Map<String, dynamic>>(
      future: firestoreService.getPlatformAnalytics(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome Banner ──────────────────────────────────
              _SuperWelcomeBanner(),
              const SizedBox(height: 24),

              // ── Platform Revenue ───────────────────────────────
              if (!isLoading)
                _PlatformRevenueCard(
                  revenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0,
                  cafes: data['totalCafes'] ?? 0,
                ),
              if (isLoading)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )),
              const SizedBox(height: 24),

              // ── Section header ─────────────────────────────────
              const _SuperSectionHeader(title: 'Platform Overview'),
              const SizedBox(height: 14),

              // ── Stats Grid ─────────────────────────────────────
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _SuperStatCard(
                    icon: Icons.store_rounded,
                    label: 'Total Cafés',
                    value: isLoading ? '…' : '${data['totalCafes'] ?? 0}',
                    sub: '${data['activeCafes'] ?? 0} active',
                    color: const Color(0xFF1565C0),
                    imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=400&q=80',
                  ),
                  _SuperStatCard(
                    icon: Icons.people_rounded,
                    label: 'Customers',
                    value: isLoading ? '…' : '${data['totalCustomers'] ?? 0}',
                    sub: '${data['totalUsers'] ?? 0} total users',
                    color: const Color(0xFF6A1B9A),
                    imageUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=400&q=80',
                  ),
                  _SuperStatCard(
                    icon: Icons.shopping_bag_rounded,
                    label: 'Total Orders',
                    value: isLoading ? '…' : '${data['totalOrders'] ?? 0}',
                    sub: '${data['pendingOrders'] ?? 0} pending',
                    color: const Color(0xFFBF360C),
                    imageUrl: 'https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=400&q=80',
                  ),
                  _SuperStatCard(
                    icon: Icons.event_seat_rounded,
                    label: 'Reservations',
                    value: isLoading ? '…' : '${data['totalReservations'] ?? 0}',
                    sub: '${data['pendingReservations'] ?? 0} pending',
                    color: const Color(0xFF2E7D32),
                    imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=400&q=80',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Quick Actions ──────────────────────────────────
              const _SuperSectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 14),
              _QuickActionsGrid(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _SuperWelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withAlpha(80),
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
              'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, err, stack)  => Container(color: const Color(0xFF0D47A1)),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xCC0D47A1), Color(0xDD1976D2)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Super Admin',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Hello, ${user?.name ?? 'Super Admin'}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Platform-wide control centre',
                          style: TextStyle(
                              color: Colors.white.withAlpha(190), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 32),
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

class _PlatformRevenueCard extends StatelessWidget {
  final double revenue;
  final int cafes;
  const _PlatformRevenueCard({required this.revenue, required this.cafes});

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
              'https://images.unsplash.com/photo-1565514020179-026b92b84bb6?auto=format&fit=crop&w=800&q=80',
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
                          ),
                        ),
                        Text(
                          'Platform Revenue · $cafes cafés',
                          style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 12),
                        ),
                      ],
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

class _SuperStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;
  final String imageUrl;

  const _SuperStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: color.withAlpha(60), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, err, stack)  => Container(color: color),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withAlpha(185), color.withAlpha(230)],
                ),
              ),
            ),
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
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withAlpha(200),
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

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'icon': Icons.store_rounded,
        'label': 'Manage Cafés',
        'color': const Color(0xFF1565C0),
        'imageUrl': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=400&q=80',
      },
      {
        'icon': Icons.person_add_rounded,
        'label': 'Assign Owners',
        'color': const Color(0xFF6A1B9A),
        'imageUrl': 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?auto=format&fit=crop&w=400&q=80',
      },
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'View Analytics',
        'color': const Color(0xFF2E7D32),
        'imageUrl': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=400&q=80',
      },
      {
        'icon': Icons.people_rounded,
        'label': 'All Users',
        'color': const Color(0xFFBF360C),
        'imageUrl': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=400&q=80',
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((a) {
        final color = a['color'] as Color;
        final imageUrl = a['imageUrl'] as String;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, err, stack)  => Container(color: color),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [color.withAlpha(210), color.withAlpha(160)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withAlpha(60)),
                        ),
                        child: Icon(a['icon'] as IconData, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          a['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SuperSectionHeader extends StatelessWidget {
  final String title;
  const _SuperSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D2B5A)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Café Management Tab
// ─────────────────────────────────────────────────────────────────
class _CafeManagementTab extends StatelessWidget {
  const _CafeManagementTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCafeProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: provider.cafes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 64, color: Color(0xFFBBBBBB)),
                  SizedBox(height: 16),
                  Text('No cafés found', style: TextStyle(color: Color(0xFF888888))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.cafes.length,
              itemBuilder: (context, index) {
                final cafe = provider.cafes[index];
                return _CafeManagementCard(
                  cafe: cafe,
                  onToggle: (isActive) => provider.toggleCafeStatus(cafe.id, isActive),
                  onAssignOwner: () => _showAssignOwnerDialog(context, cafe, provider),
                  onEdit: () => _showCafeFormDialog(context, cafe, provider),
                  onDelete: () => _showDeleteCafeDialog(context, cafe, provider),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCafeFormDialog(context, null, provider),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Café', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showCafeFormDialog(BuildContext context, CafeModel? cafe, AdminCafeProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CafeFormDialog(cafe: cafe, provider: provider),
    );
  }

  void _showDeleteCafeDialog(BuildContext context, CafeModel cafe, AdminCafeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Color(0xFFBF360C)),
            SizedBox(width: 10),
            Text('Delete Café', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(text: cafe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '? This action is permanent and cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBF360C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deleteCafe(cafe.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Café deleted successfully!' : 'Failed to delete café: ${provider.error}'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAssignOwnerDialog(
      BuildContext context, CafeModel cafe, AdminCafeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) {
        final adminUsers = provider.adminUsers;
        if (adminUsers.isEmpty) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('No Admin Users'),
            content: const Text(
                'There are no admin users available to assign. Create admin accounts first.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          );
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Assign Owner to ${cafe.name}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: adminUsers.length,
              itemBuilder: (ctx, i) {
                final u = adminUsers[i];
                final isAssigned = cafe.ownerId == u.uid;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1565C0).withAlpha(20),
                    child: Text(
                      u.name.isNotEmpty ? u.name[0].toUpperCase() : 'A',
                      style: const TextStyle(color: Color(0xFF1565C0)),
                    ),
                  ),
                  title: Text(u.name, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(u.email, style: const TextStyle(fontSize: 11)),
                  trailing: isAssigned
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32))
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await provider.assignOwner(cafe.id, u.uid);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class _CafeManagementCard extends StatelessWidget {
  final CafeModel cafe;
  final Future<bool> Function(bool) onToggle;
  final VoidCallback onAssignOwner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CafeManagementCard({
    required this.cafe,
    required this.onToggle,
    required this.onAssignOwner,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header with image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    cafe.imageUrl.trim().isEmpty
                        ? 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=600&q=80'
                        : cafe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, st) => Image.network(
                      'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=600&q=80',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x11000000), Color(0xBB000000)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          cafe.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          cafe.address,
                          style: TextStyle(
                              color: Colors.white.withAlpha(190), fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Action Overlays (Edit / Delete)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      children: [
                        Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                            onPressed: onEdit,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 14),
                            onPressed: onDelete,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: cafe.isActive
                            ? const Color(0xFF2E7D32).withAlpha(220)
                            : Colors.grey.withAlpha(220),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cafe.isActive ? 'Active' : 'Blocked',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Details row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: Color(0xFFD4A843)),
                          const SizedBox(width: 4),
                          Text(cafe.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          const Icon(Icons.reviews_rounded,
                              size: 14, color: Color(0xFF888888)),
                          const SizedBox(width: 4),
                          Text('${cafe.reviewCount} reviews',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF888888))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cafe.ownerId != null
                            ? '👤 Owner assigned'
                            : '⚠️ No owner assigned',
                        style: TextStyle(
                          fontSize: 11,
                          color: cafe.ownerId != null
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFBF360C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAssignOwner,
                    icon: const Icon(Icons.person_add_rounded, size: 15),
                    label: const Text('Assign Owner', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                      side: const BorderSide(color: Color(0xFF1565C0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onToggle(!cafe.isActive),
                    icon: Icon(
                      cafe.isActive
                          ? Icons.block_rounded
                          : Icons.check_circle_rounded,
                      size: 15,
                    ),
                    label: Text(
                      cafe.isActive ? 'Block' : 'Activate',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cafe.isActive
                          ? const Color(0xFFBF360C)
                          : const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Café Creation & Edit Dialog
// ─────────────────────────────────────────────────────────────────
class _CafeFormDialog extends StatefulWidget {
  final CafeModel? cafe;
  final AdminCafeProvider provider;

  const _CafeFormDialog({this.cafe, required this.provider});

  @override
  State<_CafeFormDialog> createState() => _CafeFormDialogState();
}

class _CafeFormDialogState extends State<_CafeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _imageUrlController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  bool _isSaving = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cafe?.name ?? '');
    _descController = TextEditingController(text: widget.cafe?.description ?? '');
    _addressController = TextEditingController(text: widget.cafe?.address ?? '');
    _cityController = TextEditingController(text: widget.cafe?.city ?? 'Hyderabad');
    _imageUrlController = TextEditingController(
        text: widget.cafe?.imageUrl ??
            'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80');
    _latController = TextEditingController(text: widget.cafe?.lat?.toString() ?? '17.3850');
    _lngController = TextEditingController(text: widget.cafe?.lng?.toString() ?? '78.4867');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _imageUrlController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    try {
      String imageUrl = _imageUrlController.text.trim();
      
      if (_selectedImage != null) {
        imageUrl = await FirestoreService().uploadProductImage(_selectedImage!);
      }

      final name = _nameController.text.trim();
      final desc = _descController.text.trim();
      final address = _addressController.text.trim();
      final city = _cityController.text.trim();
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text.trim());

      bool success;
      if (widget.cafe == null) {
        final newCafe = CafeModel(
          id: '',
          name: name,
          description: desc,
          address: address,
          city: city,
          imageUrl: imageUrl,
          rating: 4.5,
          reviewCount: 1,
          createdAt: DateTime.now(),
          isActive: true,
          isApproved: true,
          lat: lat,
          lng: lng,
        );
        success = await widget.provider.createCafe(newCafe);
      } else {
        final Map<String, dynamic> updateData = {
          'name': name,
          'description': desc,
          'address': address,
          'city': city,
          'imageUrl': imageUrl,
          'lat': lat,
          'lng': lng,
        };
        success = await widget.provider.updateCafeDetails(widget.cafe!.id, updateData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? (widget.cafe == null ? 'Café created successfully!' : 'Café updated successfully!')
                : 'Operation failed: ${widget.provider.error}'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cafe != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(isEdit ? Icons.edit_rounded : Icons.store_rounded, color: const Color(0xFF1565C0)),
          const SizedBox(width: 10),
          Text(isEdit ? 'Edit Café' : 'Add New Café', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: _isSaving
          ? const SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Saving café details...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          : SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: kIsWeb
                                      ? Image.network(
                                          _selectedImage!.path,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_selectedImage!.path),
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : widget.cafe?.imageUrl != null && widget.cafe!.imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        widget.cafe!.imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo_rounded, size: 36, color: Color(0xFF1565C0)),
                                        SizedBox(height: 8),
                                        Text('Upload Café Photo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Café Name',
                          prefixIcon: const Icon(Icons.store_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter café name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter description' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: const Icon(Icons.location_on_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter address' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: 'City',
                          prefixIcon: const Icon(Icons.location_city_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter city' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'Fallback Image URL',
                          prefixIcon: const Icon(Icons.image_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Latitude',
                                prefixIcon: const Icon(Icons.map_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return null;
                                if (double.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _lngController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Longitude',
                                prefixIcon: const Icon(Icons.map_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return null;
                                if (double.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      actions: _isSaving
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _save,
                child: Text(isEdit ? 'Save Changes' : 'Create Café', style: const TextStyle(color: Colors.white)),
              ),
            ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// User Management Tab
// ─────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────
// User Management Tab
// ─────────────────────────────────────────────────────────────────
class _UserManagementTab extends StatefulWidget {
  const _UserManagementTab();

  @override
  State<_UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<_UserManagementTab> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _filterRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      _users = await FirestoreService().getAllUsers();
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  List<UserModel> get _filtered {
    if (_filterRole == 'all') return _users;
    return _users.where((u) => u.role == _filterRole).toList();
  }

  void _showCreateAdminDialog() {
    final cafeProvider = context.read<AdminCafeProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CreateAdminUserDialog(cafeProvider: cafeProvider),
    ).then((_) => _loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Filter bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final role in ['all', 'customer', 'admin', 'superadmin'])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _filterRole = role),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _filterRole == role
                                      ? const Color(0xFF1565C0)
                                      : const Color(0xFFEDF2FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  role[0].toUpperCase() + role.substring(1),
                                  style: TextStyle(
                                    color: _filterRole == role
                                        ? Colors.white
                                        : const Color(0xFF1565C0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: Text('No users found',
                            style: TextStyle(color: Color(0xFF888888))))
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) =>
                              _UserTile(user: _filtered[index]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAdminDialog,
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Create Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Create Admin User Dialog
// ─────────────────────────────────────────────────────────────────
class _CreateAdminUserDialog extends StatefulWidget {
  final AdminCafeProvider cafeProvider;

  const _CreateAdminUserDialog({required this.cafeProvider});

  @override
  State<_CreateAdminUserDialog> createState() => _CreateAdminUserDialogState();
}

class _CreateAdminUserDialogState extends State<_CreateAdminUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedCafeId;
  bool _obscurePassword = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCafeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an associated café.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final success = await widget.cafeProvider.createAdminUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        cafeId: _selectedCafeId!,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Café Admin Account created!' : 'Failed to create account: ${widget.cafeProvider.error}'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cafes = widget.cafeProvider.cafes;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.person_add_rounded, color: Color(0xFF1565C0)),
          SizedBox(width: 10),
          Text('Create Café Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: _isSaving
          ? const SizedBox(
              height: 180,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Creating admin account...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          : SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Temporary Password',
                          prefixIcon: const Icon(Icons.lock_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCafeId,
                        decoration: InputDecoration(
                          labelText: 'Assign to Café',
                          prefixIcon: const Icon(Icons.store_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        items: cafes.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.name, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCafeId = val),
                        validator: (value) => value == null ? 'Select a café' : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      actions: _isSaving
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: const Text('Create Account', style: TextStyle(color: Colors.white)),
              ),
            ],
    );
  }
}


class _UserTile extends StatelessWidget {
  final UserModel user;
  const _UserTile({required this.user});

  Color _roleColor(String role) {
    switch (role) {
      case 'superadmin':
        return const Color(0xFF6A1B9A);
      case 'admin':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(user.role);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(user.email,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                if (user.cafeId != null)
                  Text('Café: ${user.cafeId}',
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF1565C0))),
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
              user.role,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Platform Analytics Tab
// ─────────────────────────────────────────────────────────────────
class _PlatformAnalyticsTab extends StatelessWidget {
  const _PlatformAnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: FirestoreService().getPlatformAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SuperSectionHeader(title: 'Platform Analytics'),
              const SizedBox(height: 16),

              // Revenue highlight
              _AnalyticBigCard(
                title: 'Total Platform Revenue',
                value: '₹${((data['totalRevenue'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
                icon: Icons.currency_rupee_rounded,
                color: const Color(0xFF2E7D32),
                subtitle: '${data['deliveredOrders'] ?? 0} completed orders',
              ),
              const SizedBox(height: 14),

              // Grid of analytics
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AnalyticCard(
                    title: 'Total Cafés',
                    value: '${data['totalCafes'] ?? 0}',
                    sub: '${data['activeCafes'] ?? 0} active',
                    icon: Icons.store_rounded,
                    color: const Color(0xFF1565C0),
                  ),
                  _AnalyticCard(
                    title: 'Total Users',
                    value: '${data['totalUsers'] ?? 0}',
                    sub: '${data['totalCustomers'] ?? 0} customers',
                    icon: Icons.people_rounded,
                    color: const Color(0xFF6A1B9A),
                  ),
                  _AnalyticCard(
                    title: 'Total Orders',
                    value: '${data['totalOrders'] ?? 0}',
                    sub: '${data['pendingOrders'] ?? 0} pending',
                    icon: Icons.shopping_bag_rounded,
                    color: const Color(0xFFBF360C),
                  ),
                  _AnalyticCard(
                    title: 'Menu Items',
                    value: '${data['totalProducts'] ?? 0}',
                    sub: 'across all cafés',
                    icon: Icons.restaurant_menu_rounded,
                    color: const Color(0xFFD4A843),
                  ),
                  _AnalyticCard(
                    title: 'Reservations',
                    value: '${data['totalReservations'] ?? 0}',
                    sub: '${data['pendingReservations'] ?? 0} pending',
                    icon: Icons.event_seat_rounded,
                    color: const Color(0xFF2E7D32),
                  ),
                  _AnalyticCard(
                    title: 'Delivered',
                    value: '${data['deliveredOrders'] ?? 0}',
                    sub: 'completed orders',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF00796B),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticBigCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _AnalyticBigCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withAlpha(200)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withAlpha(80), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12)),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 11)),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}

class _AnalyticCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;

  const _AnalyticCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: color.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const Spacer(),
          Text(value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
          Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF999999))),
        ],
      ),
    );
  }
}
