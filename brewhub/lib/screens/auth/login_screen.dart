import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? role;

  const LoginScreen({super.key, this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const _backgroundImage =
      'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1200&q=80';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      final user = authProvider.currentUser;
      if (user != null) {
        if (user.role == 'admin') {
          Navigator.of(context).pushReplacementNamed('/admin-dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        Fluttertoast.showToast(msg: authProvider.error ?? 'Login succeeded but couldn\'t load your profile.');
      }
    } else if (mounted) {
      Fluttertoast.showToast(msg: authProvider.error ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              _backgroundImage,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.brown.shade700);
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.5),
                    Color.fromRGBO(0, 0, 0, 0.25),
                    Color.fromRGBO(0, 0, 0, 0.65),
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
                    size: 52,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    widget.role == 'admin' ? 'Admin Portal' : 'Welcome Back',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.role == 'admin'
                        ? 'Secure access for BrewHub managers.'
                        : 'Sign in and discover your next coffee favorite.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.95),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.15),
                          blurRadius: 30,
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
                            widget.role == 'admin' ? 'Admin Login' : 'Customer Login',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please sign in to continue.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                          ),
                          const SizedBox(height: 28),
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
                          const SizedBox(height: 18),
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
                          const SizedBox(height: 24),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return CustomButton(
                                label: 'Login',
                                onPressed: _login,
                                isLoading: authProvider.isLoading,
                              );
                            },
                          ),
                          if (widget.role != 'admin') ...[
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No account yet? ',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(role: 'customer'),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Create one',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
