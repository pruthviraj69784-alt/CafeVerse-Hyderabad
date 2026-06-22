import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/product_model.dart';
import '../../services/providers/product_provider.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/state_widgets.dart';

// ─── constants ───────────────────────────────────────────────────
const _primaryBrown   = Color(0xFF452B19);
const _lightBrown     = Color(0xFF6F4E37);
const _cream          = Color(0xFFF7F3EE);
const _paleGold       = Color(0xFFF5E6D3);
const _textDark       = Color(0xFF2B1A0F);
const _textMid        = Color(0xFF8D6E63);

// ─────────────────────────────────────────────────────────────────
// Menu Management Screen
// ─────────────────────────────────────────────────────────────────
class AdminMenuManagementScreen extends StatefulWidget {
  const AdminMenuManagementScreen({super.key});

  @override
  State<AdminMenuManagementScreen> createState() =>
      _AdminMenuManagementScreenState();
}

class _AdminMenuManagementScreenState
    extends State<AdminMenuManagementScreen> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Products are already loaded by AdminDashboardScreen's initState
    // using the correct cafeId scope. No reload needed here.
  }

  List<String> _getCategories(List<ProductModel> products) {
    final cats = products.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading) {
            return const LoadingWidget(message: 'Loading products...');
          }
          if (productProvider.error != null) {
            return AppErrorWidget(
                message: productProvider.error ?? 'Something went wrong');
          }

          final categories = _getCategories(productProvider.products);
          final filtered = _selectedCategory == 'All'
              ? productProvider.products
              : productProvider.products
                  .where((p) => p.category == _selectedCategory)
                  .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          'Menu Management',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        '${productProvider.products.length} product${productProvider.products.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textMid,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Category Filter ───────────────────────────────
              if (categories.length > 1)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _primaryBrown
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : _lightBrown,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // ── Product List ──────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? Center(
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
                              child: const Icon(
                                Icons.restaurant_menu_rounded,
                                size: 40,
                                color: Color(0xFFB08060),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No products yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _textMid,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap + to add your first menu item',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFFB08060)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return _buildProductCard(
                              context, product, productProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6F4E37), Color(0xFF3B2010)],
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBrown.withAlpha(100),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const AddProductDialog(),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add Product',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    ProductProvider productProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ── Product image ───────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _paleGold,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                product.imageUrl.trim().isEmpty
                    ? 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=200&q=80'
                    : product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, e, st) => Image.network(
                  'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=200&q=80',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Details ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _paleGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _lightBrown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.available
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.available ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: product.available
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: _primaryBrown,
                    ),
                  ),
                ],
              ),
            ),

            // ── Actions ─────────────────────────────────────────
            Column(
              children: [
                _ActionButton(
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF1565C0),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => EditProductDialog(product: product),
                  ),
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.delete_rounded,
                  color: const Color(0xFFC62828),
                  onTap: () => _showDeleteDialog(
                      context, product, productProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProductModel product,
    ProductProvider productProvider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Color(0xFFC62828)),
            SizedBox(width: 10),
            Text('Delete Product',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: _textDark),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '? This action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              productProvider.deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Small reusable action icon button
// ─────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Shared dialog label widget
// ─────────────────────────────────────────────────────────────────
class _DialogSectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _DialogSectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _lightBrown),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5C3317),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Add Product Dialog
// ─────────────────────────────────────────────────────────────────
class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _nameController        = TextEditingController();
  final _priceController       = TextEditingController();
  final _categoryController    = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile?    _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _available = true;
  bool _isSaving  = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          final storage = await Permission.storage.request();
          final photos  = await Permission.photos.request();
          if (!storage.isGranted && !photos.isGranted) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Storage or Photos permission is required to pick images')),
            );
            return;
          }
        } else if (Platform.isIOS) {
          final status = await Permission.photos.request();
          if (!status.isGranted) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Photos permission is required to pick images')),
            );
            return;
          }
        }
      }
      final picker = ImagePicker();
      final image  = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        Uint8List? bytes;
        if (kIsWeb) {
          try {
            bytes = await image.readAsBytes();
          } catch (_) {
            bytes = null;
          }
        } else {
          try {
            final file = File(image.path);
            if (await file.exists()) {
              bytes = null;
            } else {
              bytes = await image.readAsBytes();
            }
          } catch (_) {
            try {
              bytes = await image.readAsBytes();
            } catch (_) {
              bytes = null;
            }
          }
        }
        setState(() {
          _selectedImage      = image;
          _selectedImageBytes = bytes;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Picked image: ${image.name}\npath: ${image.path}')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    setState(() => _isSaving = true);
    // Read cafeId synchronously before any async gaps
    final cafeId = context.read<AuthProvider>().currentUser?.cafeId;
    try {
      String imageUrl = '';
      if (_selectedImage != null) {
        try {
          imageUrl = await FirestoreService()
              .uploadProductImage(_selectedImage!)
              .timeout(const Duration(seconds: 30));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image uploaded: $imageUrl')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image upload failed: $e')),
            );
          }
          rethrow;
        }
      }
      final product = ProductModel(
        id: '',
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        available: _available,
        createdAt: DateTime.now(),
        cafeId: cafeId,
      );
      if (mounted) {
        final navigator = Navigator.of(context);
        final provider  = context.read<ProductProvider>();
        await provider
            .addProduct(product)
            .timeout(const Duration(seconds: 30));
        if (provider.error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Failed to add product: ${provider.error}')),
            );
            setState(() => _isSaving = false);
          }
          return;
        }
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _paleGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: _primaryBrown, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Product',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      'Fill in the details below',
                      style: TextStyle(fontSize: 12, color: _textMid),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFF0E8DC)),
            const SizedBox(height: 16),

            // ── Form ──────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _DialogSectionLabel(
                        label: 'Product Details',
                        icon: Icons.info_outline_rounded),
                    CustomTextField(
                      label: 'Product Name *',
                      controller: _nameController,
                      enabled: !_isSaving,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Price (₹) *',
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            enabled: !_isSaving,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Category *',
                            controller: _categoryController,
                            enabled: !_isSaving,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Description (optional)',
                      controller: _descriptionController,
                      maxLines: 2,
                      enabled: !_isSaving,
                    ),
                    const SizedBox(height: 18),

                    // ── Image picker ───────────────────────────
                    const _DialogSectionLabel(
                        label: 'Product Image',
                        icon: Icons.image_rounded),
                    _buildImagePickerSection(),
                    const SizedBox(height: 14),

                    // ── Availability toggle ────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: _paleGold,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: CheckboxListTile(
                        title: const Text(
                          'Mark as Available',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _textDark,
                          ),
                        ),
                        subtitle: Text(
                          _available
                              ? 'Visible to customers'
                              : 'Hidden from menu',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                _available ? const Color(0xFF2E7D32) : Colors.red.shade700,
                          ),
                        ),
                        value: _available,
                        activeColor: _primaryBrown,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        onChanged: _isSaving
                            ? null
                            : (v) =>
                                setState(() => _available = v ?? true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Actions ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Color(0xFFD7C4B0)),
                    ),
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: _textMid, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6F4E37), Color(0xFF3B2010)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryBrown.withAlpha(80),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isSaving ? null : _saveProduct,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Text(
                              'Add Product',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return GestureDetector(
      onTap: _isSaving ? null : _pickImage,
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _paleGold.withAlpha(120),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedImage == null
                ? const Color(0xFFD7C4B0)
                : Colors.transparent,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (kIsWeb)
                      (_selectedImageBytes != null
                          ? Image.memory(_selectedImageBytes!,
                              fit: BoxFit.cover)
                          : const SizedBox.shrink())
                    else
                      (_selectedImageBytes != null
                          ? Image.memory(_selectedImageBytes!,
                              fit: BoxFit.cover)
                          : Image.file(File(_selectedImage!.path),
                              fit: BoxFit.cover)),
                    Container(color: Colors.black.withAlpha(70)),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cached_rounded,
                              color: Colors.white, size: 28),
                          SizedBox(height: 6),
                          Text(
                            'Tap to change image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_photo_alternate_rounded,
                        size: 26, color: _lightBrown),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Upload Product Image',
                    style: TextStyle(
                      fontSize: 13,
                      color: _lightBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Tap to browse your gallery',
                    style: TextStyle(fontSize: 11, color: _textMid),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Edit Product Dialog
// ─────────────────────────────────────────────────────────────────
class EditProductDialog extends StatefulWidget {
  final ProductModel product;
  const EditProductDialog({super.key, required this.product});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late bool _available;
  XFile?     _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController        = TextEditingController(text: widget.product.name);
    _priceController       = TextEditingController(text: widget.product.price.toString());
    _categoryController    = TextEditingController(text: widget.product.category);
    _descriptionController = TextEditingController(text: widget.product.description);
    _available             = widget.product.available;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          final storage = await Permission.storage.request();
          final photos  = await Permission.photos.request();
          if (!storage.isGranted && !photos.isGranted) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Storage or Photos permission is required to pick images')),
            );
            return;
          }
        } else if (Platform.isIOS) {
          final status = await Permission.photos.request();
          if (!status.isGranted) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Photos permission is required to pick images')),
            );
            return;
          }
        }
      }
      final picker = ImagePicker();
      final image  = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        Uint8List? bytes;
        if (kIsWeb) {
          try {
            bytes = await image.readAsBytes();
          } catch (_) {
            bytes = null;
          }
        } else {
          try {
            final file = File(image.path);
            if (await file.exists()) {
              bytes = null;
            } else {
              bytes = await image.readAsBytes();
            }
          } catch (_) {
            try {
              bytes = await image.readAsBytes();
            } catch (_) {
              bytes = null;
            }
          }
        }
        setState(() {
          _selectedImage      = image;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _updateProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      String imageUrl = widget.product.imageUrl;
      if (_selectedImage != null) {
        try {
          imageUrl = await FirestoreService()
              .uploadProductImage(_selectedImage!)
              .timeout(const Duration(seconds: 30));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image uploaded: $imageUrl')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image upload failed: $e')),
            );
          }
          rethrow;
        }
      }
      final product = widget.product.copyWith(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        available: _available,
      );
      if (mounted) {
        final navigator = Navigator.of(context);
        final provider  = context.read<ProductProvider>();
        await provider
            .updateProduct(product)
            .timeout(const Duration(seconds: 30));
        if (provider.error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Failed to update product: ${provider.error}')),
            );
            setState(() => _isSaving = false);
          }
          return;
        }
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating product: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Color(0xFF1565C0), size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Product',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      widget.product.name,
                      style: const TextStyle(fontSize: 12, color: _textMid),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFF0E8DC)),
            const SizedBox(height: 16),

            // ── Form ──────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _DialogSectionLabel(
                        label: 'Product Details',
                        icon: Icons.info_outline_rounded),
                    CustomTextField(
                      label: 'Product Name',
                      controller: _nameController,
                      enabled: !_isSaving,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Price (₹)',
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            enabled: !_isSaving,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Category',
                            controller: _categoryController,
                            enabled: !_isSaving,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Description',
                      controller: _descriptionController,
                      maxLines: 2,
                      enabled: !_isSaving,
                    ),
                    const SizedBox(height: 18),
                    const _DialogSectionLabel(
                        label: 'Product Image',
                        icon: Icons.image_rounded),
                    _buildImagePickerSection(),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: _paleGold,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: CheckboxListTile(
                        title: const Text(
                          'Mark as Available',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _textDark,
                          ),
                        ),
                        subtitle: Text(
                          _available
                              ? 'Visible to customers'
                              : 'Hidden from menu',
                          style: TextStyle(
                            fontSize: 11,
                            color: _available
                                ? const Color(0xFF2E7D32)
                                : Colors.red.shade700,
                          ),
                        ),
                        value: _available,
                        activeColor: _primaryBrown,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        onChanged: _isSaving
                            ? null
                            : (v) =>
                                setState(() => _available = v ?? true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Actions ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Color(0xFFD7C4B0)),
                    ),
                    onPressed:
                        _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: _textMid, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1565C0).withAlpha(70),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isSaving ? null : _updateProduct,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return GestureDetector(
      onTap: _isSaving ? null : _pickImage,
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _paleGold.withAlpha(120),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (_selectedImage == null && widget.product.imageUrl.isEmpty)
                ? const Color(0xFFD7C4B0)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (kIsWeb)
                      (_selectedImageBytes != null
                          ? Image.memory(_selectedImageBytes!,
                              fit: BoxFit.cover)
                          : const SizedBox.shrink())
                    else
                      (_selectedImageBytes != null
                          ? Image.memory(_selectedImageBytes!,
                              fit: BoxFit.cover)
                          : Image.file(File(_selectedImage!.path),
                              fit: BoxFit.cover)),
                    Container(color: Colors.black.withAlpha(70)),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cached_rounded,
                              color: Colors.white, size: 28),
                          SizedBox(height: 6),
                          Text(
                            'Tap to change image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : widget.product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(widget.product.imageUrl,
                            fit: BoxFit.cover),
                        Container(color: Colors.black.withAlpha(70)),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cached_rounded,
                                  color: Colors.white, size: 28),
                              SizedBox(height: 6),
                              Text(
                                'Tap to change image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 26,
                            color: _lightBrown),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Upload Product Image',
                        style: TextStyle(
                          fontSize: 13,
                          color: _lightBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Tap to browse your gallery',
                        style: TextStyle(fontSize: 11, color: _textMid),
                      ),
                    ],
                  ),
      ),
    );
  }
}
