import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/cart_provider.dart';
import '../../widgets/custom_button.dart';
// removed unused import: state_widgets
import 'checkout_screen.dart';

const _primaryBrown = Color(0xFF452B19);
const _lightBrown   = Color(0xFF6F4E37);
const _cream        = Color(0xFFF7F3EE);
const _paleGold     = Color(0xFFF5E6D3);
const _textDark     = Color(0xFF2B1A0F);

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B2010), Color(0xFF6F4E37)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(22),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.white.withAlpha(45)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'My Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Review your items',
                        style:
                            TextStyle(color: Color(0xB3FFFFFF), fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Consumer<CartProvider>(
                    builder: (ctx, cart, _) => cart.cartItems.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _showClearCartDialog(ctx, cart),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(22),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white.withAlpha(45)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.delete_outline_rounded,
                                      color: Colors.white70, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Clear',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _paleGold,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 50,
                      color: Color(0xFFB08060),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add items from the menu to get started',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6F4E37), Color(0xFF3B2010)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Browse Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // ── Item count info bar ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _primaryBrown,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${cartProvider.itemCount} item${cartProvider.itemCount != 1 ? 's' : ''} in your cart',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Cart items list ──────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Image
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: _paleGold,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: item.product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      item.product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, e, st) =>
                                          const Icon(Icons.coffee_rounded,
                                              color: _lightBrown),
                                    )
                                  : const Icon(Icons.coffee_rounded,
                                      color: _lightBrown, size: 30),
                            ),
                            const SizedBox(width: 14),

                            // Name + price
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: _textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${item.product.price.toStringAsFixed(0)} each',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8D6E63),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${item.totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: _primaryBrown,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity + delete
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: _paleGold,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _QtyButton(
                                        icon: Icons.remove_rounded,
                                        onTap: item.quantity > 1
                                            ? () =>
                                                cartProvider.updateQuantity(
                                                    item.product.id,
                                                    item.quantity - 1)
                                            : null,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: _textDark,
                                          ),
                                        ),
                                      ),
                                      _QtyButton(
                                        icon: Icons.add_rounded,
                                        onTap: () =>
                                            cartProvider.updateQuantity(
                                                item.product.id,
                                                item.quantity + 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () => cartProvider
                                      .removeFromCart(item.product.id),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEE),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Color(0xFFC62828),
                                      size: 18,
                                    ),
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
              ),

              // ── Order summary + checkout ─────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(14),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Price breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF8D6E63)),
                        ),
                        Text(
                          '₹${cartProvider.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF8D6E63)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                        ),
                        Text(
                          'Free',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Color(0xFFF0E8DC)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          '₹${cartProvider.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: _primaryBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    CustomButton(
                      label: 'Proceed to Checkout',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const CheckoutScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFC62828)),
            SizedBox(width: 10),
            Text('Clear Cart',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content:
            const Text('Remove all items from your cart?'),
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
              elevation: 0,
            ),
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear All',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: onTap != null ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? _primaryBrown : const Color(0xFFBCAA9A),
        ),
      ),
    );
  }
}
