import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/providers/cafe_provider.dart';
import '../../services/providers/favorites_provider.dart';
import '../../models/cafe_model.dart';
import 'cafe_detail_screen.dart';

const _primaryBrown = Color(0xFF452B19);
const _lightBrown   = Color(0xFF6F4E37);
const _cream        = Color(0xFFF7F3EE);
const _paleGold     = Color(0xFFF5E6D3);
const _textDark     = Color(0xFF2B1A0F);
const _textMid      = Color(0xFF8D6E63);

class CafeListScreen extends StatefulWidget {
  final bool showFilters;

  const CafeListScreen({super.key, this.showFilters = true});

  @override
  State<CafeListScreen> createState() => _CafeListScreenState();
}

class _CafeListScreenState extends State<CafeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<CafeProvider>();
    _searchController.text = provider.searchQuery;
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
      appBar: AppBar(
        title: const Text(
          'Explore Cafes',
          style: TextStyle(color: _textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _primaryBrown),
            onPressed: () => context.read<CafeProvider>().loadCafes(),
          ),
        ],
      ),
      body: Consumer<CafeProvider>(
        builder: (context, provider, _) {
          final cafes = provider.filteredCafes;

          return Column(
            children: [
              // Search & Filter header
              if (widget.showFilters) _buildSearchAndFilters(provider),

              // Cafe list or empty state
              Expanded(
                child: cafes.isEmpty
                    ? _buildEmptyState(provider)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: cafes.length,
                        itemBuilder: (context, index) {
                          return _buildCafeCard(cafes[index], provider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(CafeProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Column(
        children: [
          // Search Field
          Hero(
            tag: 'search_bar',
            child: Material(
              color: Colors.transparent,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => provider.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search cafes, areas, or ambiance...',
                  prefixIcon: const Icon(Icons.search_rounded, color: _lightBrown),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: _textMid),
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
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
            ),
          ),
          const SizedBox(height: 12),

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Area Filter Dropdown Chip
                _buildFilterDropdown(
                  label: 'Area: ${provider.selectedArea}',
                  isActive: provider.selectedArea != 'All',
                  onTap: () => _showAreaPicker(context, provider),
                ),
                const SizedBox(width: 8),

                // Budget Filter Dropdown Chip
                _buildFilterDropdown(
                  label: 'Budget: ${provider.selectedBudget}',
                  isActive: provider.selectedBudget != 'All',
                  onTap: () => _showBudgetPicker(context, provider),
                ),
                const SizedBox(width: 8),

                // Ambiance Filter Dropdown Chip
                _buildFilterDropdown(
                  label: 'Ambiance: ${provider.selectedAmbiance}',
                  isActive: provider.selectedAmbiance != 'All',
                  onTap: () => _showAmbiancePicker(context, provider),
                ),

                if (provider.selectedArea != 'All' ||
                    provider.selectedBudget != 'All' ||
                    provider.selectedAmbiance != 'All' ||
                    provider.searchQuery.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      provider.resetFilters();
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _primaryBrown : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? _primaryBrown : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : _textDark,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: isActive ? Colors.white : _textMid,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCafeCard(CafeModel cafe, CafeProvider provider) {
    return Consumer<FavoritesProvider>(
      builder: (context, favProvider, _) {
        final isFav = favProvider.isFavorite(cafe.id);
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
            margin: const EdgeInsets.only(bottom: 18),
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
                // Image and Favorite Button Stack
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: cafe.imageUrl.trim().isEmpty
                            ? 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=500&q=80'
                            : cafe.imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                          height: 160,
                          child: const Center(
                            child: CircularProgressIndicator(color: _primaryBrown),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          height: 160,
                          child: const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => favProvider.toggleFavorite(cafe.id),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.red : _lightBrown,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    // Cost category badge
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(160),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cafe.costForTwo < 500
                              ? '💰 Budget friendly'
                              : cafe.costForTwo <= 1000
                                  ? '💰 Mid-range'
                                  : '💎 Premium',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Card details
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              cafe.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _textDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.green, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  cafe.rating.toString(),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: _lightBrown, size: 13),
                          const SizedBox(width: 2),
                          Text(
                            cafe.area,
                            style: const TextStyle(
                              color: _textMid,
                              fontSize: 12,
                            ),
                          ),
                          if (distance > 0.0) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.near_me_rounded, color: _lightBrown, size: 13),
                            const SizedBox(width: 2),
                            Text(
                              '${distance.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                color: _textMid,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(width: 10),
                          const Icon(Icons.currency_rupee_rounded, color: _lightBrown, size: 13),
                          Text(
                            '${cafe.costForTwo} for 2',
                            style: const TextStyle(
                              color: _textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cafe.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                      if (cafe.ambianceTags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: cafe.ambianceTags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _cream,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: _lightBrown,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(CafeProvider provider) {
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
            'No matching cafes found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your filters or search query.',
            style: TextStyle(
              fontSize: 13,
              color: _textMid,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.resetFilters(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset All Filters', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Pickers using Bottom Sheets
  void _showAreaPicker(BuildContext context, CafeProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final areas = provider.areas;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Area', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: areas.length,
                  itemBuilder: (context, index) {
                    final area = areas[index];
                    final isSelected = provider.selectedArea == area;
                    return ListTile(
                      title: Text(area, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      trailing: isSelected ? const Icon(Icons.check_rounded, color: _primaryBrown) : null,
                      onTap: () {
                        provider.selectArea(area);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBudgetPicker(BuildContext context, CafeProvider provider) {
    final budgets = ['All', 'Under ₹500', '₹500 - ₹1000', '₹1000+'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final budget = budgets[index];
                  final isSelected = provider.selectedBudget == budget;
                  return ListTile(
                    title: Text(budget, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    trailing: isSelected ? const Icon(Icons.check_rounded, color: _primaryBrown) : null,
                    onTap: () {
                      provider.selectBudget(budget);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAmbiancePicker(BuildContext context, CafeProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final tags = provider.ambianceTags;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Ambiance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    final isSelected = provider.selectedAmbiance == tag;
                    return ListTile(
                      title: Text(tag, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      trailing: isSelected ? const Icon(Icons.check_rounded, color: _primaryBrown) : null,
                      onTap: () {
                        provider.selectAmbiance(tag);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
