import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../models/cart_item_model.dart';
import '../../services/providers/cart_provider.dart';
import '../../widgets/custom_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  void _addToCart() {
    final cartProvider = context.read<CartProvider>();
    cartProvider.addToCart(
      CartItemModel(product: widget.product, quantity: _quantity),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.product.name} x$_quantity added to cart',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey.shade200,
              child: widget.product.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.local_cafe,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '₹${widget.product.price.toStringAsFixed(0)}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Category and Rating
                  Row(
                    children: [
                      Chip(
                        label: Text(widget.product.category),
                        backgroundColor:
                            Theme.of(context).colorScheme.primary.withAlpha(51),
                      ),
                      const SizedBox(width: 8),
                      if (widget.product.rating > 0) ...[
                        const Icon(Icons.star, size: 20, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.product.rating.toStringAsFixed(1)} '
                          '(${widget.product.reviewCount} reviews)',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  // Availability
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.product.available
                          ? Colors.green.withAlpha(26)
                          : Colors.red.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.product.available
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: widget.product.available
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.product.available
                              ? 'Available'
                              : 'Not Available',
                          style: TextStyle(
                            color: widget.product.available
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1
                        ? () {
                            setState(() => _quantity--);
                          }
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _quantity.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _quantity++);
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Add to Cart Button
            CustomButton(
              label:
                  'Add to Cart - ₹${(widget.product.price * _quantity).toStringAsFixed(0)}',
              onPressed: _addToCart,
            ),
          ],
        ),
      ),
    );
  }
}
