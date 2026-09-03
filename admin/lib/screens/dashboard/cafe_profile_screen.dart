import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/admin_cafe_provider.dart';
import '../../models/cafe_model.dart';

class CafeProfileScreen extends StatefulWidget {
  const CafeProfileScreen({super.key});

  @override
  State<CafeProfileScreen> createState() => _CafeProfileScreenState();
}

class _CafeProfileScreenState extends State<CafeProfileScreen> {
  static const _brown = Color(0xFF3B2010);

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cafe = context.read<AdminCafeProvider>().selectedCafe;
      if (cafe != null) _populateFields(cafe);
    });
  }

  void _populateFields(CafeModel cafe) {
    _nameController.text = cafe.name;
    _descController.text = cafe.description;
    _addressController.text = cafe.address;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cafe = context.read<AdminCafeProvider>().selectedCafe;
    if (cafe == null) return;

    setState(() => _isSaving = true);
    final success = await context.read<AdminCafeProvider>().updateCafeDetails(cafe.id, {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'address': _addressController.text.trim(),
    });
    setState(() {
      _isSaving = false;
      if (success) _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Café profile updated!' : 'Failed to update. Try again.'),
          backgroundColor: success ? const Color(0xFF2E7D32) : const Color(0xFFBF360C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCafeProvider>();
    final cafe = provider.selectedCafe;
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Café Hero ──────────────────────────────────────────
          if (cafe != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _brown.withAlpha(60),
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
                      cafe.imageUrl.trim().isEmpty
                          ? 'https://images.unsplash.com/photo-1498804103079-a6351b050096?auto=format&fit=crop&w=1200&q=80'
                          : cafe.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, st) => Image.network(
                        'https://images.unsplash.com/photo-1498804103079-a6351b050096?auto=format&fit=crop&w=1200&q=80',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xCC000000)],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              if (cafe.isActive)
                                _Badge(
                                    label: 'Active',
                                    color: const Color(0xFF2E7D32))
                              else
                                _Badge(label: 'Inactive', color: Colors.grey),
                              const SizedBox(width: 8),
                              if (cafe.isApproved)
                                _Badge(
                                    label: 'Approved',
                                    color: const Color(0xFF1565C0)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cafe.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            cafe.address,
                            style: TextStyle(
                              color: Colors.white.withAlpha(190),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 22),

          // ── Cafe Stats Row ─────────────────────────────────────
          if (cafe != null) ...[
            Row(
              children: [
                _InfoChip(
                    icon: Icons.star_rounded,
                    label: '${cafe.rating.toStringAsFixed(1)} Rating',
                    color: const Color(0xFFD4A843)),
                const SizedBox(width: 10),
                _InfoChip(
                    icon: Icons.rate_review_rounded,
                    label: '${cafe.reviewCount} Reviews',
                    color: const Color(0xFF6F4E37)),
              ],
            ),
            const SizedBox(height: 22),

            // ── Tags ──────────────────────────────────────────────
            if (cafe.tags.isNotEmpty) ...[
              _SectionLabel(label: 'Tags'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cafe.tags
                    .map((tag) => Chip(
                          label: Text(tag,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF3B2010))),
                          backgroundColor: const Color(0xFFF5F0E8),
                          side: const BorderSide(color: Color(0xFFDDD0C0)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 22),
            ],

            // ── Opening Hours ─────────────────────────────────────
            if (cafe.openingHours.isNotEmpty) ...[
              _SectionLabel(label: 'Opening Hours'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: cafe.openingHours.entries.map((entry) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.schedule_rounded,
                          size: 18, color: Color(0xFF6F4E37)),
                      title: Text(entry.key,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      trailing: Text(entry.value,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 22),
            ],
          ],

          // ── Edit Profile Section ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel(label: 'Café Details'),
              if (!_isEditing)
                GestureDetector(
                  onTap: () {
                    if (cafe != null) _populateFields(cafe);
                    setState(() => _isEditing = true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _brown.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 14, color: _brown),
                        SizedBox(width: 6),
                        Text('Edit',
                            style: TextStyle(
                                color: _brown,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          if (!_isEditing && cafe != null) ...[
            _ReadonlyField(label: 'Name', value: cafe.name),
            _ReadonlyField(label: 'Description', value: cafe.description),
            _ReadonlyField(label: 'Address', value: cafe.address),
          ] else ...[
            _EditField(label: 'Café Name', controller: _nameController, icon: Icons.store_rounded),
            const SizedBox(height: 14),
            _EditField(
                label: 'Description',
                controller: _descController,
                icon: Icons.description_rounded,
                maxLines: 4),
            const SizedBox(height: 14),
            _EditField(
                label: 'Address', controller: _addressController, icon: Icons.location_on_rounded),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isEditing = false),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],

          // ── Admin Info ────────────────────────────────────────
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _brown.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: _brown, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Admin',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _brown.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Café Owner',
                    style: TextStyle(
                        color: _brown, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2B1A0F)),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ReadonlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEE8E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;

  const _EditField({
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6F4E37)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3B2010), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
