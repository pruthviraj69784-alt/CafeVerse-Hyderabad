import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../models/cafe_model.dart';
import '../../models/cart_item_model.dart';
import '../../services/providers/cafe_provider.dart';
import '../../services/providers/favorites_provider.dart';
import '../../services/providers/cart_provider.dart';
import '../bookings/table_booking_screen.dart';
import '../../screens/cart/cart_screen.dart';

const _primaryBrown = Color(0xFF452B19);
const _lightBrown   = Color(0xFF6F4E37);
const _cream        = Color(0xFFF7F3EE);
const _paleGold     = Color(0xFFF5E6D3);
const _goldAccent   = Color(0xFFD4A843);
const _textDark     = Color(0xFF2B1A0F);
const _textMid      = Color(0xFF8D6E63);

class CafeDetailScreen extends StatefulWidget {
  final CafeModel cafe;

  const CafeDetailScreen({super.key, required this.cafe});

  @override
  State<CafeDetailScreen> createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends State<CafeDetailScreen> {
  final PageController _pageController = PageController();
  bool _showMenuTab = true; // true = Menu, false = Reviews

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cafeProvider = context.read<CafeProvider>();
      cafeProvider.loadCafeProducts(widget.cafe.id);
      cafeProvider.loadCafeReviews(widget.cafe.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Launches Google Maps directions using coordinates or address
  Future<void> _launchDirections() async {
    final lat = widget.cafe.latitude;
    final lng = widget.cafe.longitude;
    final query = Uri.encodeComponent('${widget.cafe.name}, ${widget.cafe.area}, Hyderabad');
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$query');
    final genericUrl = Uri.parse('https://maps.google.com/?q=$query');

    try {
      if (await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
        // Success
      } else if (await launchUrl(genericUrl, mode: LaunchMode.externalApplication)) {
        // Success
      } else {
        throw 'Could not launch maps URL';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open map: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawImages = widget.cafe.photoUrls.isNotEmpty ? widget.cafe.photoUrls : [widget.cafe.imageUrl];
    final images = rawImages.where((url) => url.trim().isNotEmpty).toList();
    if (images.isEmpty) {
      images.add('https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1200&q=80');
    }
    final cafeProvider = context.watch<CafeProvider>();
    final distance = cafeProvider.getDistanceToCafe(widget.cafe);

    return Scaffold(
      backgroundColor: _cream,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Photo Carousel Header
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index],
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, url, err) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image_rounded, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                // Back Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 16,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, favProvider, _) {
                      final isFav = favProvider.isFavorite(widget.cafe.id);
                      return GestureDetector(
                        onTap: () => favProvider.toggleFavorite(widget.cafe.id),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(100),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.red : Colors.white,
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Cart Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 64,
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, _) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(100),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 22),
                            ),
                            if (cartProvider.itemCount > 0)
                              Positioned(
                                top: -2,
                                right: -2,
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
                ),
                // Page Indicator Dots
                if (images.length > 1)
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: images.length,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: _goldAccent,
                          dotColor: Colors.white70,
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 2. Cafe Info Card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.cafe.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.green, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              widget.cafe.rating.toString(),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Area, Distance, and Cost indicator
                  Wrap(
                    spacing: 15,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded, color: _lightBrown, size: 15),
                          const SizedBox(width: 4),
                          Text(
                            widget.cafe.area,
                            style: const TextStyle(fontSize: 14, color: _textMid, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      if (distance > 0.0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.near_me_rounded, color: _lightBrown, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              '${distance.toStringAsFixed(1)} km away',
                              style: const TextStyle(fontSize: 14, color: _textMid, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.currency_rupee_rounded, color: _lightBrown, size: 15),
                          const SizedBox(width: 2),
                          Text(
                            '₹${widget.cafe.costForTwo} for two',
                            style: const TextStyle(fontSize: 14, color: _textDark, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Ambiance tags
                  if (widget.cafe.ambianceTags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.cafe.ambianceTags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _paleGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: _primaryBrown,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'About the Cafe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.cafe.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 3. Quick Action Buttons (Directions & Book Table)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _launchDirections,
                          icon: const Icon(Icons.directions_rounded, color: Colors.white, size: 18),
                          label: const Text('Get Directions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _lightBrown,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TableBookingScreen(cafe: widget.cafe),
                              ),
                            );
                          },
                          icon: const Icon(Icons.table_bar_rounded, color: _primaryBrown, size: 18),
                          label: const Text('Book Table', style: TextStyle(color: _primaryBrown, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _primaryBrown, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 4. Tab Switcher (Menu vs Reviews)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showMenuTab = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _showMenuTab ? _primaryBrown : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Browse Menu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _showMenuTab ? Colors.white : _textDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showMenuTab = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_showMenuTab ? _primaryBrown : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Reviews',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: !_showMenuTab ? Colors.white : _textDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Tab Content
                  _showMenuTab ? _buildMenuTab(cafeProvider) : _buildReviewsTab(cafeProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTab(CafeProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: _primaryBrown),
        ),
      );
    }

    final products = provider.selectedCafeProducts;
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No menu items available for this cafe yet.',
            style: TextStyle(color: _textMid, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              // Item thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl.trim().isEmpty
                      ? 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=200&q=80'
                      : product.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) => Container(color: _cream, width: 60, height: 60),
                  errorWidget: (context, url, error) => Container(
                    color: _cream,
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.local_cafe_rounded, color: _lightBrown),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Item info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _primaryBrown),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Add to Cart button
              Consumer<CartProvider>(
                builder: (context, cartProvider, _) {
                  return ElevatedButton(
                    onPressed: () {
                      cartProvider.addToCart(
                        CartItemModel(product: product, quantity: 1),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: _textDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _paleGold,
                      foregroundColor: _primaryBrown,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(CafeProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: _primaryBrown),
        ),
      );
    }

    final reviews = provider.selectedCafeReviews;
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No reviews for this cafe yet. Be the first to add one!',
            style: TextStyle(color: _textMid, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cafe.rating.toString(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _textDark),
                  ),
                  const SizedBox(height: 2),
                  RatingBarIndicator(
                    rating: widget.cafe.rating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star_rounded,
                      color: _goldAccent,
                    ),
                    itemCount: 5,
                    itemSize: 16.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on ${reviews.length} ratings',
                    style: const TextStyle(fontSize: 11, color: _textMid),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Reviews list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final rev = reviews[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rev.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _textDark),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(rev.createdAt),
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  RatingBarIndicator(
                    rating: rev.rating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star_rounded,
                      color: _goldAccent,
                    ),
                    itemCount: 5,
                    itemSize: 13.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rev.comment,
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.35),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
