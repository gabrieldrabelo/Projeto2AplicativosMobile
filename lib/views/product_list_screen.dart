// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductController _productController = ProductController();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final products = await _productController.getProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  void _showProductForm({Product? product}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product?.name ?? '');
    final unitController = TextEditingController(text: product?.unit ?? 'un');
    final stockQuantityController = TextEditingController(text: product?.stockQuantity.toString() ?? '0');
    final salePriceController = TextEditingController(text: product?.salePrice.toString() ?? '0');
    final statusController = TextEditingController(text: product?.status.toString() ?? '0');
    final costController = TextEditingController(text: product?.cost?.toString() ?? '');
    final barcodeController = TextEditingController(text: product?.barcode ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: unitController.text,
                  decoration: const InputDecoration(labelText: 'Unit *'),
                  items: const [
                    DropdownMenuItem(value: 'un', child: Text('Unit (un)')),
                    DropdownMenuItem(value: 'cx', child: Text('Box (cx)')),
                    DropdownMenuItem(value: 'kg', child: Text('Kilogram (kg)')),
                    DropdownMenuItem(value: 'lt', child: Text('Liter (lt)')),
                    DropdownMenuItem(value: 'ml', child: Text('Milliliter (ml)')),
                  ],
                  onChanged: (value) {
                    unitController.text = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a unit';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: stockQuantityController,
                  decoration: const InputDecoration(labelText: 'Stock Quantity *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter stock quantity';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: salePriceController,
                  decoration: const InputDecoration(labelText: 'Sale Price *'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter sale price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: statusController.text,
                  decoration: const InputDecoration(labelText: 'Status *'),
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('Active')),
                    DropdownMenuItem(value: '1', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    statusController.text = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: costController,
                  decoration: const InputDecoration(labelText: 'Cost'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: barcodeController,
                  decoration: const InputDecoration(labelText: 'Barcode'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                if (product == null) {
                  // Add new product
                  final newProduct = Product(
                    name: nameController.text,
                    unit: unitController.text,
                    stockQuantity: double.parse(stockQuantityController.text),
                    salePrice: double.parse(salePriceController.text),
                    status: int.parse(statusController.text),
                    cost: costController.text.isNotEmpty ? double.parse(costController.text) : null,
                    barcode: barcodeController.text.isNotEmpty ? barcodeController.text : null, code: '', stock: double.parse(stockQuantityController.text),
                  );
                  await _productController.addProduct(newProduct);
                } else {
                  // Update existing product
                  final updatedProduct = Product(
                    id: product.id,
                    name: nameController.text,
                    unit: unitController.text,
                    stockQuantity: double.parse(stockQuantityController.text),
                    salePrice: double.parse(salePriceController.text),
                    status: int.parse(statusController.text),
                    cost: costController.text.isNotEmpty ? double.parse(costController.text) : null,
                    barcode: barcodeController.text.isNotEmpty ? barcodeController.text : null,
                    lastModified: product.lastModified, code: '', stock: 0,
                  );
                  await _productController.updateProduct(updatedProduct);
                }
                Navigator.pop(context);
                _loadProducts();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _productController.deleteProduct(product.id!);
              Navigator.pop(context);
              _loadProducts();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No products found'))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                          '${product.unit} - Stock: ${product.stockQuantity} - Price: ${product.salePrice}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showProductForm(product: product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(product),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
