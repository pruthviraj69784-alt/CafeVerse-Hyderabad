import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'constants/app_theme.dart';
import 'services/providers/auth_provider.dart';
import 'services/providers/product_provider.dart';
import 'services/providers/order_provider.dart';
import 'services/providers/admin_cafe_provider.dart';
import 'services/providers/admin_reservation_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/admin_dashboard_screen.dart';
import 'screens/dashboard/superadmin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CafeVerseAdmin());
}

class CafeVerseAdmin extends StatelessWidget {
  const CafeVerseAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminCafeProvider()),
        ChangeNotifierProvider(create: (_) => AdminReservationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CaféVerse Admin',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
          '/superadmin-dashboard': (context) => const SuperAdminDashboardScreen(),
        },
      ),
    );
  }
}
