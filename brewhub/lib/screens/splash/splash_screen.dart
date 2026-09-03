import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../services/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final fb_auth.User? firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      int checkCount = 0;
      while (authProvider.currentUser == null && authProvider.error == null && checkCount < 30) {
        await Future.delayed(const Duration(milliseconds: 200));
        checkCount++;
        if (!mounted) return;
      }
    }

    if (!mounted) return;
    final currentUser = authProvider.currentUser;

    if (firebaseUser != null && currentUser != null) {
      // User is logged in
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // User is not logged in
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_cafe,
                size: 84,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'BrewHub',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your coffee shop companion',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
