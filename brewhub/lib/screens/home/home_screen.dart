import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item_model.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/product_provider.dart';
import '../../services/providers/cart_provider.dart';
import '../../widgets/state_widgets.dart';
import '../../widgets/product_card.dart';
import '../menu/menu_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../orders/order_tracking_screen.dart';

// ─── Design tokens ────────────────────────────────────────────────
const _primaryBrown = Color(0xFF452B19);
const _lightBrown   = Color(0xFF6F4E37);
const _cream        = Color(0xFFF7F3EE);
const _paleGold     = Color(0xFFF5E6D3);
const _textDark     = Color(0xFF2B1A0F);
const _textMid      = Color(0xFF8D6E63);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _heroImage =
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=1200&q=80';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<ProductProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B2010), Color(0xFF6F4E37)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(22),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withAlpha(45)),
                    ),
                    child: const Icon(Icons.coffee_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'BrewHub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Consumer<AuthProvider>(
                        builder: (ctx, auth, _) {
                          final name = auth.currentUser?.name;
                          final greeting = (name != null && name.isNotEmpty)
                              ? 'Hi, ${name.split(' ').first}!'
                              : 'Good day!';
                          return Text(
                            greeting,
                            style: TextStyle(
                              color: Colors.white.withAlpha(175),
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Cart icon with badge
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, _) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const CartScreen()),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(22),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withAlpha(45)),
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
                                    color: Color(0xFFD4A843),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${cartProvider.itemCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
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
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Orders'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, -4)),
        ],
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
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _primaryBrown.withAlpha(18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        color: isSelected ? _primaryBrown : Colors.grey.shade500,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? _primaryBrown
                              : Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
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
        return const OrdersTabContent();
      case 2:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Banner ────────────────────────────────────────
          Container(
            height: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: _primaryBrown.withAlpha(55),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(_heroImage, fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x44000000),
                          Color(0x11000000),
                          Color(0xCC000000),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A843).withAlpha(220),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '☕  Premium Coffee',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Coffee Crafted\nfor You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Premium blends for every taste & mood.',
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const MenuScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 11),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(30),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.restaurant_menu_rounded,
                                    color: _primaryBrown, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Browse Menu',
                                  style: TextStyle(
                                    color: _primaryBrown,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Quick actions ──────────────────────────────────────
          Row(
            children: [
              _QuickAction(
                icon: Icons.local_cafe_rounded,
                label: 'Full Menu',
                color: _primaryBrown,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MenuScreen()),
                ),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: Icons.shopping_bag_rounded,
                label: 'My Cart',
                color: const Color(0xFF1565C0),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Consumer<CartProvider>(
                builder: (ctx, cart, _) => _QuickAction(
                  icon: Icons.receipt_long_rounded,
                  label: 'Orders',
                  color: const Color(0xFF2E7D32),
                  badge: cart.itemCount > 0 ? '${cart.itemCount}' : null,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Featured Products header ────────────────────────────
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: _primaryBrown,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Featured Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MenuScreen()),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _paleGold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'See all →',
                    style: TextStyle(
                      color: _lightBrown,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Products Grid ──────────────────────────────────────
          Consumer<ProductProvider>(
            builder: (context, productProvider, _) {
              if (productProvider.isLoading) {
                return const LoadingWidget(message: 'Loading products...');
              }
              if (productProvider.error != null) {
                return AppErrorWidget(
                    message: productProvider.error ?? '');
              }
              final products =
                  productProvider.products.take(4).toList();
              if (products.isEmpty) {
                return const EmptyWidget(
                    message: 'No products available');
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: products[index],
                    onTap: () => Navigator.of(context).pushNamed(
                      '/product-details',
                      arguments: products[index],
                    ),
                    onAddToCart: () {
                      context.read<CartProvider>().addToCart(
                            CartItemModel(
                                product: products[index], quantity: 1),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${products[index].name} added to cart'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: const Color(0xFF2B1A0F),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Quick Action tile ─────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 3)),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withAlpha(18),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              if (badge != null)
                Positioned(
                  top: 0,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4A843),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
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

// ─── Orders tab wrapper ───────────────────────────────────────────
class OrdersTabContent extends StatelessWidget {
  const OrdersTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _paleGold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  size: 40, color: _lightBrown),
            ),
            const SizedBox(height: 16),
            const Text(
              'Login to view your orders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textMid,
              ),
            ),
          ],
        ),
      );
    }
    return const OrderTrackingScreen();
  }
}
