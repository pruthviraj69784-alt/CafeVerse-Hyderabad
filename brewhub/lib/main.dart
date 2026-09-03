import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'constants/app_theme.dart';
import 'services/providers/auth_provider.dart';
import 'services/providers/product_provider.dart';
import 'services/providers/cart_provider.dart';
import 'services/providers/order_provider.dart';
import 'services/providers/cafe_provider.dart';
import 'services/providers/favorites_provider.dart';
import 'services/providers/comparison_provider.dart';
import 'services/providers/reservation_provider.dart';
import 'services/seed_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'customer/home/home_screen.dart';
import 'screens/menu/menu_screen.dart';
import 'screens/menu/product_details_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/cart/checkout_screen.dart';
import 'screens/orders/order_tracking_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'customer/search/price_comparison_screen.dart';
import 'models/product_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SeedService.seedDatabaseIfEmpty();
  runApp(const BrewHub());
}

class BrewHub extends StatelessWidget {
  const BrewHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CafeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ComparisonProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CaféVerse',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(role: 'customer'),
          '/home': (context) => const HomeScreen(),
          '/menu': (context) => const MenuScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/order-tracking': (context) => const OrderTrackingScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/price-comparison': (context) => const PriceComparisonScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product-details') {
            final product = settings.arguments as ProductModel;
            return MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            );
          }
          return null;
        },
      ),
    );
  }
}
