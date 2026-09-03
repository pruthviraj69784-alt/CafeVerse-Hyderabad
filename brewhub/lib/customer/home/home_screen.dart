import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/cafe_provider.dart';
import '../../services/providers/favorites_provider.dart';
import '../../services/providers/cart_provider.dart';
import '../../screens/cart/cart_screen.dart';
import '../../models/cafe_model.dart';
import '../cafes/cafe_list_screen.dart';
import '../cafes/cafe_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../search/price_comparison_screen.dart';
import '../bookings/reservations_screen.dart';

// Design tokens matching AppTheme
const _primaryBrown = Color(0xFF452B19);
const _lightBrown   = Color(0xFF6F4E37);
const _cream        = Color(0xFFF7F3EE);
const _paleGold     = Color(0xFFF5E6D3);
const _goldAccent   = Color(0xFFD4A843);
const _textDark     = Color(0xFF2B1A0F);
const _textMid      = Color(0xFF8D6E63);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CafeProvider>().loadCafes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryBrown, _lightBrown],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // Logo Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(50)),
                  ),
                  child: const Icon(Icons.coffee_maker_rounded, color: _paleGold, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'CaféVerse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: _goldAccent, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          'Hyderabad',
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                // Cart icon with badge
                Consumer<CartProvider>(
                  builder: (context, cartProvider, _) {
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withAlpha(50)),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          if (cartProvider.itemCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: _goldAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${cartProvider.itemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                // User Profile avatar indicator
                Consumer<AuthProvider>(
                  builder: (ctx, auth, _) {
                    final name = auth.currentUser?.name ?? 'User';
                    return GestureDetector(
                      onTap: () => setState(() => _currentIndex = 4), // Switch to profile tab
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _paleGold,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: _primaryBrown,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.explore_rounded, 'label': 'Explore'},
      {'icon': Icons.table_bar_rounded, 'label': 'Bookings'},
      {'icon': Icons.favorite_rounded, 'label': 'Favorites'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final isSelected = _currentIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryBrown.withAlpha(15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        navItems[index]['icon'] as IconData,
                        color: isSelected ? _primaryBrown : Colors.grey.shade400,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        navItems[index]['label'] as String,
                        style: TextStyle(
                          color: isSelected ? _primaryBrown : Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
        return _buildHomeContent();
      case 1:
        return const CafeListScreen(showFilters: true);
      case 2:
        return const ReservationsScreen();
      case 3:
        return const FavoritesTabScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Consumer<CafeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: _primaryBrown));
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: _lightBrown),
                const SizedBox(height: 12),
                Text(
                  'Error loading cafes: ${provider.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.loadCafes(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryBrown, foregroundColor: Colors.white),
                ),
              ],
            ),
          );
        }

        final cafes = provider.cafes;
        if (cafes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.coffee_outlined, size: 64, color: _lightBrown),
                const SizedBox(height: 16),
                const Text(
                  'No cafes available yet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pull down to refresh',
                  style: TextStyle(color: _textMid),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => provider.loadCafes(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryBrown, foregroundColor: Colors.white),
                ),
              ],
            ),
          );
        }

        // Filtering for display sections
        final trendingCafes = cafes.where((c) => c.rating >= 4.5).toList();
        final premiumCafes  = cafes.where((c) => c.costForTwo >= 1000).toList();
        final budgetCafes   = cafes.where((c) => c.costForTwo > 0 && c.costForTwo < 800).toList();
        // Cafes NOT in any special category (e.g. admin-created with default rating/cost)
        final newCafes = cafes
            .where((c) => c.rating < 4.5 && c.costForTwo == 0)
            .toList();

        return RefreshIndicator(
          onRefresh: () => provider.loadCafes(),
          color: _primaryBrown,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Interactive Search Bar (Opens Comparison Page)
                Hero(
                  tag: 'search_bar',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        readOnly: true,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PriceComparisonScreen(),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Compare item prices (e.g. Cappuccino)...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: _lightBrown),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Area Quick Select Chips
                const Text(
                  'Explore Neighborhoods',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildAreaChip('All'),
                      _buildAreaChip('Banjara Hills'),
                      _buildAreaChip('Jubilee Hills'),
                      _buildAreaChip('Madhapur'),
                      _buildAreaChip('Gachibowli'),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 3. All Cafes — always shown, shows every cafe including new ones
                _buildSectionHeader('☕ All Cafes (${cafes.length})', () {
                  provider.resetFilters();
                  setState(() => _currentIndex = 1);
                }),
                const SizedBox(height: 12),
                SizedBox(
                  height: 230,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cafes.length,
                    itemBuilder: (context, index) {
                      return _buildHorizontalCafeCard(cafes[index], provider);
                    },
                  ),
                ),
                const SizedBox(height: 25),

                // 4. Trending Cafes (rating >= 4.5)
                if (trendingCafes.isNotEmpty) ...[
                  _buildSectionHeader('🔥 Trending Cafes', () {
                    provider.resetFilters();
                    provider.selectBudget('All');
                    setState(() => _currentIndex = 1);
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: trendingCafes.length,
                      itemBuilder: (context, index) {
                        return _buildHorizontalCafeCard(trendingCafes[index], provider);
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                ],

                // 5. Premium Cafes (costForTwo >= 1000)
                if (premiumCafes.isNotEmpty) ...[
                  _buildSectionHeader('💎 Premium Experiences', () {
                    provider.resetFilters();
                    provider.selectBudget('₹1000+');
                    setState(() => _currentIndex = 1);
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: premiumCafes.length,
                      itemBuilder: (context, index) {
                        return _buildHorizontalCafeCard(premiumCafes[index], provider);
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                ],

                // 6. Budget Cafes (costForTwo > 0 and < 800)
                if (budgetCafes.isNotEmpty) ...[
                  _buildSectionHeader('💰 Smart Budget Spots', () {
                    provider.resetFilters();
                    provider.selectBudget('Under ₹500');
                    setState(() => _currentIndex = 1);
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: budgetCafes.length,
                      itemBuilder: (context, index) {
                        return _buildHorizontalCafeCard(budgetCafes[index], provider);
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                ],

                // 7. Newly Added Cafes (admin-created, no rating/cost yet)
                if (newCafes.isNotEmpty) ...[
                  _buildSectionHeader('🆕 Newly Added', () {
                    provider.resetFilters();
                    setState(() => _currentIndex = 1);
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: newCafes.length,
                      itemBuilder: (context, index) {
                        return _buildHorizontalCafeCard(newCafes[index], provider);
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                ],

                // 8. Ambiance tag section
                _buildSectionHeader('📸 Ambiance Collections', () {
                  provider.resetFilters();
                  setState(() => _currentIndex = 1);
                }),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildAmbianceCollectionCard('Study Friendly', Icons.menu_book_rounded, Colors.teal),
                      _buildAmbianceCollectionCard('Work Friendly', Icons.laptop_chromebook_rounded, Colors.indigo),
                      _buildAmbianceCollectionCard('Date Friendly', Icons.favorite_rounded, Colors.pink),
                      _buildAmbianceCollectionCard('Minimalist', Icons.spa_rounded, Colors.blueGrey),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildAreaChip(String label) {
    return Consumer<CafeProvider>(
      builder: (context, provider, _) {
        final isSelected = provider.selectedArea == label;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                provider.selectArea(label);
                setState(() {
                  _currentIndex = 1; // Navigate to Explore list view to display filtered results
                });
              }
            },
            selectedColor: _primaryBrown,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : _textDark,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? _primaryBrown : Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textDark,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Row(
            children: [
              Text(
                'See all',
                style: TextStyle(
                  color: _lightBrown,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _lightBrown, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCafeCard(CafeModel cafe, CafeProvider provider) {
    final distance = provider.getDistanceToCafe(cafe);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CafeDetailScreen(cafe: cafe),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: CachedNetworkImage(
                imageUrl: cafe.imageUrl.trim().isEmpty
                    ? 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=500&q=80'
                    : cafe.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _primaryBrown),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cafe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: _lightBrown, size: 11),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          cafe.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _textMid,
                          ),
                        ),
                      ),
                      if (distance > 0.0) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.near_me_rounded, color: _lightBrown, size: 10),
                        Text(
                          '${distance.toStringAsFixed(1)}km',
                          style: const TextStyle(fontSize: 10, color: _textMid),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.green, size: 12),
                            const SizedBox(width: 1),
                            Text(
                              cafe.rating.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${cafe.costForTwo} for 2',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbianceCollectionCard(String label, IconData icon, Color color) {
    return Consumer<CafeProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: () {
            provider.resetFilters();
            provider.selectAmbiance(label);
            setState(() {
              _currentIndex = 1;
            });
          },
          child: Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withAlpha(20),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Favorites Tab Screen ──────────────────────────────────────────
class FavoritesTabScreen extends StatelessWidget {
  const FavoritesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(color: _textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer2<CafeProvider, FavoritesProvider>(
        builder: (context, cafeProvider, favProvider, _) {
          final favoriteCafes = cafeProvider.cafes
              .where((cafe) => favProvider.isFavorite(cafe.id))
              .toList();

          if (favoriteCafes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _paleGold,
                    child: const Icon(Icons.favorite_rounded, size: 40, color: _lightBrown),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No favorites added yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap the heart icon on any cafe details\npage to save them here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: _textMid,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            itemCount: favoriteCafes.length,
            itemBuilder: (context, index) {
              final cafe = favoriteCafes[index];
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
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: cafe.imageUrl.trim().isEmpty
                          ? 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=500&q=80'
                          : cafe.imageUrl,
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade100,
                        width: 65,
                        height: 65,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        width: 65,
                        height: 65,
                        child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(
                    cafe.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: _textDark),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: _lightBrown, size: 12),
                          const SizedBox(width: 2),
                          Text(cafe.area, style: const TextStyle(fontSize: 12, color: _textMid)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${cafe.costForTwo} for 2',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryBrown),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                    onPressed: () {
                      favProvider.toggleFavorite(cafe.id);
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CafeDetailScreen(cafe: cafe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
