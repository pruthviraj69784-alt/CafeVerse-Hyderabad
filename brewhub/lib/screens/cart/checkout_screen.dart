import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/order_model.dart';
import '../../services/providers/cart_provider.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/order_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartProvider = context.read<CartProvider>();
    final authProvider = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (cartProvider.cartItems.isEmpty) {
      Fluttertoast.showToast(msg: 'Cart is empty');
      return;
    }

    if (authProvider.currentUser == null) {
      Fluttertoast.showToast(msg: 'Please login to place order');
      return;
    }

    // Create order items
    List<OrderItemModel> orderItems = cartProvider.cartItems
        .map((item) => OrderItemModel(
              productId: item.product.id,
              productName: item.product.name,
              price: item.product.price,
              quantity: item.quantity,
            ))
        .toList();

    // Retrieve cafeId from the first item in the cart
    final String cafeId = cartProvider.cartItems.isNotEmpty
        ? cartProvider.cartItems.first.product.cafeId
        : '';

    // Create order
    final order = OrderModel(
      orderId: '', // Firestore will generate the ID
      userId: authProvider.currentUser!.uid,
      cafeId: cafeId,
      items: orderItems,
      total: cartProvider.totalPrice,
      status: 'Pending',
      createdAt: DateTime.now(),
      specialNotes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    final success = await orderProvider.createOrder(order, cafeId);

    if (!success) {
      Fluttertoast.showToast(msg: orderProvider.error ?? 'Failed to place order.');
      return;
    }

    if (mounted) {
      cartProvider.clearCart();
      Fluttertoast.showToast(msg: 'Order placed successfully!');
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/order-tracking',
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Consumer<CartProvider>(
                  builder: (context, cartProvider, _) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            ...cartProvider.cartItems.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.product.name} x${item.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Text(
                                      '₹${item.totalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${cartProvider.totalPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'Delivery Details',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.currentUser;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${user?.name ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Email: ${user?.email ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Address: ${user?.address ?? 'Not provided'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Update your profile to change delivery details',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'Special Notes (Optional)',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Add special requests',
                  hint: 'E.g., Extra hot, light cream, etc.',
                  controller: _notesController,
                  maxLines: 4,
                  minLines: 3,
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withAlpha(31),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Cash on Delivery — pay when your order arrives at your door.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Consumer<OrderProvider>(
                  builder: (context, orderProvider, _) {
                    return CustomButton(
                      label: 'Place Order',
                      onPressed: _placeOrder,
                      isLoading: orderProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
