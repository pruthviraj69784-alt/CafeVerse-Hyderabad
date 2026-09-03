import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String? role;

  const RegisterScreen({super.key, this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(msg: 'Passwords do not match');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: widget.role ?? 'customer',
    );

    if (success && mounted) {
      Fluttertoast.showToast(msg: 'Registration successful!');
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted) {
      Fluttertoast.showToast(msg: authProvider.error ?? 'Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=1200&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.brown.shade700),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.45),
                    Color.fromRGBO(0, 0, 0, 0.12),
                    Color.fromRGBO(0, 0, 0, 0.7),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.local_cafe,
                    size: 56,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Start Your Brew Journey',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your BrewHub account and unlock new coffee moments.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.95),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Account',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign up with your details below.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                          ),
                          const SizedBox(height: 28),
                          CustomTextField(
                            label: 'Full Name',
                            controller: _nameController,
                            prefixIcon: Icons.person,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Name is required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Email is required';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Password',
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: Icons.lock,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Password is required';
                              if (value!.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Confirm Password',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            prefixIcon: Icons.lock,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Confirm password is required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return CustomButton(
                                label: 'Register',
                                onPressed: _register,
                                isLoading: authProvider.isLoading,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(role: 'customer'),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Login',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
