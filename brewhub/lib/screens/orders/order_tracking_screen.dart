import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../services/providers/auth_provider.dart';
import '../../widgets/state_widgets.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Orders'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.currentUser == null) {
            return const Center(child: Text('Please login to view orders'));
          }

          final firestoreService = FirestoreService();
          return StreamBuilder<List<OrderModel>>(
            stream: firestoreService.getUserOrdersStream(authProvider.currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget(message: 'Loading orders...');
              }

              if (snapshot.hasError) {
                return AppErrorWidget(
                  message: 'Error: ${snapshot.error}',
                );
              }

              final orders = snapshot.data ?? [];
              if (orders.isEmpty) {
                return const EmptyWidget(
                  message: 'No orders yet',
                  icon: Icons.shopping_bag,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(order: order);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Preparing':
        return Colors.blue;
      case 'Ready':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule;
      case 'Preparing':
        return Icons.local_cafe;
      case 'Ready':
        return Icons.done_all;
      case 'Delivered':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(
          _getStatusIcon(order.status),
          color: _getStatusColor(order.status),
        ),
        title: Text('Order #${order.orderId.substring(0, 8)}'),
        subtitle: Text(
          order.status,
          style: TextStyle(
            color: _getStatusColor(order.status),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text('₹${order.total.toStringAsFixed(0)}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Items
                Text(
                  'Items:',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.productName} x${item.quantity}'),
                          Text('₹${item.totalPrice.toStringAsFixed(0)}'),
                        ],
                      ),
                    )),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 8),
                // Timeline
                Text(
                  'Timeline:',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTimeline(order),
                const SizedBox(height: 12),
                // Special Notes
                if (order.specialNotes != null && order.specialNotes!.isNotEmpty) ...[
                  Text(
                    'Special Notes:',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(order.specialNotes!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(OrderModel order) {
    final statuses = ['Pending', 'Preparing', 'Ready', 'Delivered'];
    final currentIndex = statuses.indexOf(order.status);

    return Column(
      children: List.generate(statuses.length, (index) {
        final isCompleted = index <= currentIndex;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      isCompleted ? _getStatusColor(statuses[index]) : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.pending,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  statuses[index],
                  style: TextStyle(
                    color: isCompleted ? Colors.black : Colors.grey,
                    fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
