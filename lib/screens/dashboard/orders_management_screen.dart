import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../services/providers/order_provider.dart';
import '../../widgets/state_widgets.dart';

class AdminOrdersManagementScreen extends StatefulWidget {
  const AdminOrdersManagementScreen({super.key});

  @override
  State<AdminOrdersManagementScreen> createState() =>
      _AdminOrdersManagementScreenState();
}

class _AdminOrdersManagementScreenState
    extends State<AdminOrdersManagementScreen> {
  String _filterStatus = 'All';

  static const _primaryBrown = Color(0xFF452B19);

  static const _statusConfig = {
    'All': {'color': Color(0xFF452B19), 'icon': Icons.list_alt_rounded},
    'Pending': {'color': Color(0xFFE65100), 'icon': Icons.pending_actions_rounded},
    'Preparing': {'color': Color(0xFF1565C0), 'icon': Icons.soup_kitchen_rounded},
    'Ready': {'color': Color(0xFF6A1B9A), 'icon': Icons.done_all_rounded},
    'Delivered': {'color': Color(0xFF2E7D32), 'icon': Icons.check_circle_rounded},
  };

  @override
  void initState() {
    super.initState();
    // Re-trigger orders load to ensure stream is active when this tab is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderProvider>();
      // Stream already set up by AdminDashboardScreen — nothing extra needed.
      // If orders list is empty, attempt a fresh load.
      if (provider.orders.isEmpty && !provider.isLoading) {
        provider.loadAllOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: Column(
        children: [
          // ── Section Header ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _primaryBrown,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Orders Management',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B1A0F),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Live indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2E7D32).withAlpha(60)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 7, color: Color(0xFF2E7D32)),
                          SizedBox(width: 4),
                          Text(
                            'Live',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Manual refresh button
                    Consumer<OrderProvider>(
                      builder: (context, op, _) => IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6F4E37)),
                        tooltip: 'Refresh orders',
                        onPressed: op.isLoading ? null : () => op.loadAllOrders(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Consumer<OrderProvider>(
                    builder: (context, op, _) => Text(
                      '${op.orders.length} total orders',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8D6E63),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Filter Chips ────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusConfig.keys.map((status) {
                  final isSelected = _filterStatus == status;
                  final color = _statusConfig[status]!['color'] as Color;
                  final icon = _statusConfig[status]!['icon'] as IconData;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterStatus = status),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 15,
                              color: isSelected ? Colors.white : color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: TextStyle(
                                color: isSelected ? Colors.white : color,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Orders List ─────────────────────────────────────────
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, _) {
                if (orderProvider.isLoading) {
                  return const LoadingWidget(message: 'Loading orders...');
                }
                if (orderProvider.error != null) {
                  return AppErrorWidget(message: orderProvider.error ?? '');
                }

                final orders = _filterStatus == 'All'
                    ? orderProvider.orders
                    : orderProvider.orders
                        .where((o) => o.status == _filterStatus)
                        .toList();

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5E6D3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.inbox_rounded,
                            size: 40,
                            color: Color(0xFFB08060),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No $_filterStatus orders',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8D6E63),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Orders will appear here once placed',
                          style: TextStyle(fontSize: 13, color: Color(0xFFB08060)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderCard(context, order, orderProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    OrderProvider orderProvider,
  ) {
    final statusColor = _getStatusColor(order.status);
    final statusIcon = _statusConfig[order.status]?['icon'] as IconData? ??
        Icons.help_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(18),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: statusColor.withAlpha(50)),
            ),
            child: Icon(statusIcon, color: statusColor, size: 22),
          ),
          title: Text(
            'Order #${order.orderId.substring(0, 8).toUpperCase()}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF2B1A0F),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${order.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2B1A0F),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB08060)),
            ],
          ),
          children: [
            const Divider(height: 1, color: Color(0xFFF0E8DC)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items header
                  const Row(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 16, color: Color(0xFF8D6E63)),
                      SizedBox(width: 6),
                      Text(
                        'Order Items',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF5C3317),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5E6D3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${item.quantity}x',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6F4E37),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2B1A0F),
                                ),
                              ),
                            ),
                            Text(
                              '₹${item.totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF452B19),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6D3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF452B19),
                          ),
                        ),
                        Text(
                          '₹${order.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF3B2010),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status update
                  const Row(
                    children: [
                      Icon(Icons.update_rounded, size: 16, color: Color(0xFF8D6E63)),
                      SizedBox(width: 6),
                      Text(
                        'Update Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF5C3317),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Pending', 'Preparing', 'Ready', 'Delivered']
                        .map((status) {
                      final isCurrentStatus = order.status == status;
                      final sColor = _getStatusColor(status);
                      return GestureDetector(
                        onTap: !isCurrentStatus
                            ? () => orderProvider.updateOrderStatus(
                                  order.orderId,
                                  status,
                                )
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isCurrentStatus ? sColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrentStatus
                                  ? sColor
                                  : sColor.withAlpha(80),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isCurrentStatus ? Colors.white : sColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFE65100);
      case 'Preparing':
        return const Color(0xFF1565C0);
      case 'Ready':
        return const Color(0xFF6A1B9A);
      case 'Delivered':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF757575);
    }
  }
}
