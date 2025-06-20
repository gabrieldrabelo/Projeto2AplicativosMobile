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
  String _status = 'draft';
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

  final clients = await _clientController.getClients();
  final products = await _productController.getProducts();

  setState(() {
    _clients = clients;
    _products = products;
  });

  if (widget.order != null) {
    final order = await _orderController.getOrderById(widget.order!.id!);
    if (order != null) {
      setState(() {
        if (_clients.isNotEmpty) {
          _selectedClient = _clients.firstWhere(
            (client) => client.id == order.clientId,
            orElse: () => _clients.first,
          );
        } else {
          _selectedClient = Client(
            id: 0,
            name: 'Selecione um cliente',
            type: 'F',
            cpfCnpj: '',
          );
        }
        _orderItems = order.items;
        _orderPayments = order.payments;
        _total = order.totalOrder;
        _status = order.status;
        _notes = order.notes ?? '';
      });
      _updateTotal();
    }
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
                    orderId: widget.order?.id ?? 0,
                    quantity: quantity,
                    totalItem: quantity * price,
                    productName: selectedProduct!.name,
                    price: price,
                    unit: selectedProduct!.unit,
                  );

                  this.setState(() {
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
    String paymentType = 'cash';
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Payment Type'),
                  value: paymentType,
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'credit_card', child: Text('Credit Card')),
                    DropdownMenuItem(value: 'debit_card', child: Text('Debit Card')),
                    DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'check', child: Text('Check')),
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
                    orderId: widget.order?.id ?? 0,
                    value: amount,
                    paymentType: paymentType,
                    description: description.isNotEmpty ? description : null,
                  );

                  this.setState(() {
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
        // Calculate total from items
        double total = 0.0;
        for (var item in _orderItems) {
          total += item.quantity * item.price;
        }

        if (widget.order == null) {
          // Create new order
          final newOrder = Order(
            clientId: _selectedClient!.id!,
            userId: 1, // Assuming a default user ID
            totalOrder: total,
            creationDate: DateTime.now().toIso8601String(),
            clientName: _selectedClient!.name,
            status: _status,
            notes: _notes.isNotEmpty ? _notes : null,
          );

          final orderId = await _orderController.addOrder(newOrder);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order #$orderId created successfully')),
          );
        } else {
          // Update existing order
          final updatedOrder = Order(
            id: widget.order!.id,
            clientId: _selectedClient!.id!,
            userId: widget.order!.userId,
            totalOrder: total,
            creationDate: widget.order!.creationDate,
            lastModified: DateTime.now().toIso8601String(),
            clientName: _selectedClient!.name,
            status: _status,
            notes: _notes.isNotEmpty ? _notes : null,
            items: _orderItems,
            payments: _orderPayments,
          );

          await _orderController.updateOrder(updatedOrder);
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

  String _getPaymentTypeText(String paymentType) {
    switch (paymentType) {
      case 'cash':
        return 'Cash';
      case 'credit_card':
        return 'Credit Card';
      case 'debit_card':
        return 'Debit Card';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'check':
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
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: _status,
                      items: const [
                        DropdownMenuItem(value: 'draft', child: Text('Draft')),
                        DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                        DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                        DropdownMenuItem(value: 'canceled', child: Text('Canceled')),
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
                                  title: Text(item.productName ?? 'Produto'),
                                  subtitle: Text(
                                      '${item.quantity} ${item.unit} x R\$${item.price.toStringAsFixed(2)}'),
                                  trailing: SizedBox(
                                    width: 120,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'R\$${(item.quantity * item.price).toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
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
                              'R\$${_total.toStringAsFixed(2)}',
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
                                  subtitle: payment.description != null && payment.description!.isNotEmpty
                                      ? Text(payment.description!)
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'R\$${payment.value.toStringAsFixed(2)}',
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