import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/providers/cafe_provider.dart';
import '../../services/providers/comparison_provider.dart';
import '../cafes/cafe_detail_screen.dart';

const _primaryBrown = Color(0xFF452B19);
const _lightBrown   = Color(0xFF6F4E37);
const _cream        = Color(0xFFF7F3EE);
const _paleGold     = Color(0xFFF5E6D3);
const _textDark     = Color(0xFF2B1A0F);
const _textMid      = Color(0xFF8D6E63);

class PriceComparisonScreen extends StatefulWidget {
  const PriceComparisonScreen({super.key});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'Price'; // Price, Proximity, Rating

  @override
  void initState() {
    super.initState();
    final compProvider = context.read<ComparisonProvider>();
    _searchController.text = compProvider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch(String query) {
    final cafeProvider = context.read<CafeProvider>();
    context.read<ComparisonProvider>().searchAndCompare(
      query,
      cafeProvider.cafes,
      userLat: cafeProvider.userLat,
      userLng: cafeProvider.userLng,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: const Text(
          'Compare Prices',
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
      body: Column(
        children: [
          // Search Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: _searchController.text.isEmpty,
                  onSubmitted: _triggerSearch,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search item (e.g. Cappuccino, Pizza)...',
                    prefixIcon: const Icon(Icons.search_rounded, color: _lightBrown),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: _textMid),
                            onPressed: () {
                              _searchController.clear();
                              _triggerSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: _cream.withAlpha(150),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Sort Options
                Row(
                  children: [
                    const Text('Sort by: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textMid)),
                    const SizedBox(width: 8),
                    _buildSortTab('Price', Icons.payments_outlined),
                    const SizedBox(width: 8),
                    _buildSortTab('Rating', Icons.star_outline_rounded),
                    const SizedBox(width: 8),
                    _buildSortTab('Proximity', Icons.near_me_outlined),
                  ],
                ),
              ],
            ),
          ),

          // Search results list
          Expanded(
            child: Consumer<ComparisonProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: _primaryBrown));
                }

                if (provider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (provider.searchQuery.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: _paleGold,
                          child: const Icon(Icons.compare_arrows_rounded, size: 40, color: _lightBrown),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Search menu items to compare',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Compare cappuccino, burgers, pasta prices\nacross all cafes in Hyderabad.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: _textMid),
                        ),
                      ],
                    ),
                  );
                }

                final results = provider.comparisonResults;
                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: _paleGold,
                          child: const Icon(Icons.search_off_rounded, size: 36, color: _lightBrown),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No matching items found',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No cafe serves "${provider.searchQuery}" yet.',
                          style: const TextStyle(fontSize: 12.5, color: _textMid),
                        ),
                      ],
                    ),
                  );
                }

                final cheapestId = provider.cheapestCafeId;
                final bestRatedId = provider.bestRatedCafeId;
                final nearestId = provider.nearestCafeId;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final res = results[index];
                    final isCheapest = cheapestId == res.cafe.id;
                    final isBestRated = bestRatedId == res.cafe.id;
                    final isNearest = nearestId == res.cafe.id;

                    return _buildComparisonCard(res, isCheapest, isBestRated, isNearest);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortTab(String value, IconData icon) {
    final isSelected = _selectedSort == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSort = value;
        });
        context.read<ComparisonProvider>().sortResults(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _primaryBrown : _cream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : _primaryBrown),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : _primaryBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(ComparisonResult res, bool isCheapest, bool isBestRated, bool isNearest) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CafeDetailScreen(cafe: res.cafe),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: res.product.imageUrl.trim().isEmpty
                      ? 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=200&q=80'
                      : res.product.imageUrl,
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade100,
                    width: 75,
                    height: 75,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    width: 75,
                    height: 75,
                    child: const Icon(Icons.local_cafe_rounded, color: _lightBrown),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Detail Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item price and name row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            res.product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textDark),
                          ),
                        ),
                        Text(
                          '₹${res.product.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _primaryBrown),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Cafe name and location
                    Text(
                      res.cafe.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _lightBrown),
                    ),
                    const SizedBox(height: 4),

                    // Location, distance, rating
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: _textMid, size: 12),
                        const SizedBox(width: 1),
                        Text(res.cafe.area, style: const TextStyle(fontSize: 11.5, color: _textMid)),
                        
                        if (res.distance > 0.0) ...[
                          const SizedBox(width: 10),
                          const Icon(Icons.near_me_rounded, color: _textMid, size: 12),
                          const SizedBox(width: 1),
                          Text('${res.distance.toStringAsFixed(1)} km away', style: const TextStyle(fontSize: 11.5, color: _textMid)),
                        ],

                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.green, size: 12),
                              const SizedBox(width: 1),
                              Text(
                                res.cafe.rating.toString(),
                                style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Badges row
                    if (isCheapest || isBestRated || isNearest) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (isCheapest)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green.shade200, width: 0.5),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 10),
                                  SizedBox(width: 3),
                                  Text('Cheapest Choice', style: TextStyle(color: Colors.green, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          if (isBestRated)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange.shade200, width: 0.5),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.stars_rounded, color: Colors.orange, size: 10),
                                  SizedBox(width: 3),
                                  Text('Top Rated Cafe', style: TextStyle(color: Colors.orange, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          if (isNearest && res.distance > 0.0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue.shade200, width: 0.5),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.near_me_rounded, color: Colors.blue, size: 10),
                                  SizedBox(width: 3),
                                  Text('Closest to You', style: TextStyle(color: Colors.blue, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
