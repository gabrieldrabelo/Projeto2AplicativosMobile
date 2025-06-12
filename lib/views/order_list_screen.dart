import 'package:flutter/material.dart';
import '../controllers/order_controller.dart';
import '../models/order.dart';
import 'order_form_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderController _orderController = OrderController();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    final orders = await _orderController.getOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  void _navigateToOrderForm({Order? order}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderFormScreen(order: order),
      ),
    );

    if (result == true) {
      _loadOrders();
    }
  }

  void _confirmDelete(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete order #${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _orderController.deleteOrder(order.id!);
              Navigator.pop(context);
              _loadOrders();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getOrderStatusText(int status) {
    switch (status) {
      case 0:
        return 'Draft';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Delivered';
      case 3:
        return 'Canceled';
      default:
        return 'Unknown';
    }
  }

  Color _getOrderStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Order #${order.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Client: ${order.clientName}'),
                            Text('Date: ${order.orderDate}'),
                            Text('Total: ${order.total.toStringAsFixed(2)}'),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getOrderStatusColor(order.status as int),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getOrderStatusText(order.status as int),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _navigateToOrderForm(order: order),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmDelete(order),
                            ),
                          ],
                        ),
                        onTap: () => _navigateToOrderForm(order: order),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToOrderForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}