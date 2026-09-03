import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item_model.dart';
import '../../services/providers/product_provider.dart';
import '../../services/providers/cart_provider.dart';
import '../../widgets/state_widgets.dart';
import '../../widgets/product_card.dart';
import 'product_details_screen.dart';

const _primaryBrown = Color(0xFF452B19);
const _lightBrown   = Color(0xFF6F4E37);
const _cream        = Color(0xFFF7F3EE);
// removed unused local color tokens (_paleGold, _textDark)

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      productProvider.loadProducts();
      productProvider.loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(22),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.white.withAlpha(45)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Our Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Find your perfect brew',
                        style: TextStyle(
                            color: Color(0xB3FFFFFF), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search drinks, snacks...',
                  hintStyle: const TextStyle(
                      color: Color(0xFFBCAA9A), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF8D6E63)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(Icons.close_rounded,
                              color: Color(0xFF8D6E63)),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // ── Category filter ────────────────────────────────────
          Consumer<ProductProvider>(
            builder: (context, productProvider, _) {
              if (productProvider.categories.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 8,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // All chip
                      _CategoryChip(
                        label: 'All',
                        isSelected: productProvider.selectedCategory == null ||
                            productProvider.selectedCategory == '',
                        onTap: () => productProvider.filterByCategory(''),
                      ),
                      ...productProvider.categories.map(
                        (cat) => _CategoryChip(
                          label: cat,
                          isSelected:
                              productProvider.selectedCategory == cat,
                          onTap: () =>
                              productProvider.filterByCategory(cat),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // ── Products grid ──────────────────────────────────────
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                if (productProvider.isLoading) {
                  return const LoadingWidget(
                      message: 'Loading products...');
                }
                if (productProvider.error != null) {
                  return AppErrorWidget(
                      message: productProvider.error ?? '');
                }

                var products = productProvider.products;

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  products = products
                      .where((p) =>
                          p.name.toLowerCase().contains(_searchQuery) ||
                          p.category.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                if (products.isEmpty) {
                  return const EmptyWidget(
                      message: 'No products found');
                }

                return GridView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(product: product),
                        ),
                      ),
                      onAddToCart: () {
                        context.read<CartProvider>().addToCart(
                              CartItemModel(
                                  product: product, quantity: 1),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${product.name} added to cart'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            backgroundColor:
                                const Color(0xFF2B1A0F),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _primaryBrown : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : _lightBrown,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
