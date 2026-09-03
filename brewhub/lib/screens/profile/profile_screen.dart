import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
    );
    if (!mounted) return;
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _logout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: Text('Please login'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Profile Info
                if (_isEditing) ...[
                  Text(
                    'Edit Profile',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Address',
                    controller: _addressController,
                    prefixIcon: Icons.location_on,
                    maxLines: 3,
                    minLines: 2,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Save',
                          onPressed: _saveProfile,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _isEditing = false);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileField('Name', user.name, Icons.person),
                        const SizedBox(height: 12),
                        _buildProfileField('Email', user.email, Icons.email),
                        const SizedBox(height: 12),
                        _buildProfileField(
                          'Phone',
                          user.phone ?? 'Not provided',
                          Icons.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildProfileField(
                          'Address',
                          user.address ?? 'Not provided',
                          Icons.location_on,
                        ),
                        const SizedBox(height: 12),
                        _buildProfileField(
                          'Role',
                          user.role.toUpperCase(),
                          Icons.admin_panel_settings,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Logout Button
                CustomButton(
                  label: 'Logout',
                  onPressed: _logout,
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
