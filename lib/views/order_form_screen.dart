import 'package:flutter/material.dart';
import '../controllers/order_controller.dart';
import '../controllers/client_controller.dart';
import '../controllers/product_controller.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/order_payment.dart';
import '../models/client.dart';
import '../models/product.dart';

class OrderFormScreen extends StatefulWidget {
  final Order? order;

  const OrderFormScreen({Key? key, this.order}) : super(key: key);

  @override
  _OrderFormScreenState createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final OrderController _orderController = OrderController();
  final ClientController _clientController = ClientController();
  final ProductController _productController = ProductController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  List<Client> _clients = [];
  List<Product> _products = [];
  Client? _selectedClient;
  List<OrderItem> _orderItems = [];
  List<OrderPayment> _orderPayments = [];
  double _total = 0.0;
  int _status = 0;
  String _notes = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load clients and products
    final clients = await _clientController.getClients();
    final products = await _productController.getProducts();

    setState(() {
      _clients = clients;
      _products = products;
    });

    // If editing an existing order, load its data
    if (widget.order != null) {
      final order = widget.order!;
      final orderItems = await _orderController.getOrderItems(order.id!);
      final orderPayments = await _orderController.getOrderPayments(order.id!);

      setState(() {
        _selectedClient = _clients.firstWhere(
          (client) => client.id == order.clientId,
          orElse: () => _clients.isNotEmpty ? _clients.first : null,
        );
        _orderItems = orderItems;
        _orderPayments = orderPayments;
        _total = order.total;
        _status = order.status;
        _notes = order.notes ?? '';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _updateTotal() {
    double total = 0.0;
    for (var item in _orderItems) {
      total += item.quantity * item.price;
    }
    setState(() {
      _total = total;
    });
  }

  void _showAddItemDialog() {
    Product? selectedProduct;
    double quantity = 1.0;
    double price = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Item'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Product>(
                  decoration: const InputDecoration(labelText: 'Product'),
                  value: selectedProduct,
                  items: _products.map((product) {
                    return DropdownMenuItem<Product>(
                      value: product,
                      child: Text(product.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProduct = value;
                      if (value != null) {
                        price = value.salePrice;
                      }
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  initialValue: quantity.toString(),
                  onChanged: (value) {
                    setState(() {
                      quantity = double.tryParse(value) ?? 1.0;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  initialValue: price.toString(),
                  onChanged: (value) {
                    setState(() {
                      price = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedProduct != null && quantity > 0 && price > 0) {
                  final newItem = OrderItem(
                    productId: selectedProduct!.id!,
                    productName: selectedProduct!.name,
                    quantity: quantity,
                    price: price,
                    unit: selectedProduct!.unit,
                  );

                  setState(() {
                    _orderItems.add(newItem);
                    _updateTotal();
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog() {
    int paymentType = 0;
    double amount = _total;
    String description = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Payment'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Payment Type'),
                  value: paymentType,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Cash')),
                    DropdownMenuItem(value: 1, child: Text('Credit Card')),
                    DropdownMenuItem(value: 2, child: Text('Debit Card')),
                    DropdownMenuItem(value: 3, child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 4, child: Text('Check')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      paymentType = value!;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  initialValue: amount.toString(),
                  onChanged: (value) {
                    setState(() {
                      amount = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (amount > 0) {
                  final newPayment = OrderPayment(
                    paymentType: paymentType,
                    amount: amount,
                    description: description,
                  );

                  setState(() {
                    _orderPayments.add(newPayment);
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOrder() async {
    if (_formKey.currentState!.validate() && _selectedClient != null && _orderItems.isNotEmpty) {
      setState(() {
        _isSaving = true;
      });

      try {
        if (widget.order == null) {
          // Create new order
          final newOrder = Order(
            clientId: _selectedClient!.id!,
            clientName: _selectedClient!.name,
            orderDate: DateTime.now().toIso8601String(),
            total: _total,
            status: _status,
            notes: _notes.isNotEmpty ? _notes : null,
          );

          final orderId = await _orderController.addOrder(newOrder, _orderItems, _orderPayments);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order #$orderId created successfully')),
          );
        } else {
          // Update existing order
          final updatedOrder = Order(
            id: widget.order!.id,
            clientId: _selectedClient!.id!,
            clientName: _selectedClient!.name,
            orderDate: widget.order!.orderDate,
            total: _total,
            status: _status,
            notes: _notes.isNotEmpty ? _notes : null,
            lastModified: widget.order!.lastModified,
          );

          await _orderController.updateOrder(updatedOrder, _orderItems, _orderPayments);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order #${widget.order!.id} updated successfully')),
          );
        }

        setState(() {
          _isSaving = false;
        });

        Navigator.pop(context, true);
      } catch (e) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  String _getPaymentTypeText(int paymentType) {
    switch (paymentType) {
      case 0:
        return 'Cash';
      case 1:
        return 'Credit Card';
      case 2:
        return 'Debit Card';
      case 3:
        return 'Bank Transfer';
      case 4:
        return 'Check';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'New Order' : 'Edit Order #${widget.order!.id}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client selection
                    DropdownButtonFormField<Client>(
                      decoration: const InputDecoration(
                        labelText: 'Client *',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedClient,
                      items: _clients.map((client) {
                        return DropdownMenuItem<Client>(
                          value: client,
                          child: Text(client.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClient = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a client';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Order status
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: _status,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Draft')),
                        DropdownMenuItem(value: 1, child: Text('Confirmed')),
                        DropdownMenuItem(value: 2, child: Text('Delivered')),
                        DropdownMenuItem(value: 3, child: Text('Canceled')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _status = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      initialValue: _notes,
                      onChanged: (value) {
                        setState(() {
                          _notes = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Order items section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Items',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAddItemDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _orderItems.isEmpty
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No items added yet'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _orderItems.length,
                            itemBuilder: (context, index) {
                              final item = _orderItems[index];
                              return Card(
                                child: ListTile(
                                  title: Text(item.productName),
                                  subtitle: Text(
                                      '${item.quantity} ${item.unit} x $${item.price.toStringAsFixed(2)}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$${(item.quantity * item.price).toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            _orderItems.removeAt(index);
                                            _updateTotal();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 16),

                    // Total
                    Card(
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$${_total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payments section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payments',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAddPaymentDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Payment'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _orderPayments.isEmpty
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No payments added yet'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _orderPayments.length,
                            itemBuilder: (context, index) {
                              final payment = _orderPayments[index];
                              return Card(
                                child: ListTile(
                                  title: Text(_getPaymentTypeText(payment.paymentType)),
                                  subtitle: payment.description.isNotEmpty
                                      ? Text(payment.description)
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$${payment.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            _orderPayments.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveOrder,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator()
                            : const Text('Save Order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}