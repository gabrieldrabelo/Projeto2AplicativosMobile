import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
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
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: product?.name ?? '');
    final _unitController = TextEditingController(text: product?.unit ?? 'un');
    final _stockQuantityController = TextEditingController(text: product?.stockQuantity.toString() ?? '0');
    final _salePriceController = TextEditingController(text: product?.salePrice.toString() ?? '0');
    final _statusController = TextEditingController(text: product?.status.toString() ?? '0');
    final _costController = TextEditingController(text: product?.cost?.toString() ?? '');
    final _barcodeController = TextEditingController(text: product?.barcode ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _unitController.text,
                  decoration: const InputDecoration(labelText: 'Unit *'),
                  items: const [
                    DropdownMenuItem(value: 'un', child: Text('Unit (un)')),
                    DropdownMenuItem(value: 'cx', child: Text('Box (cx)')),
                    DropdownMenuItem(value: 'kg', child: Text('Kilogram (kg)')),
                    DropdownMenuItem(value: 'lt', child: Text('Liter (lt)')),
                    DropdownMenuItem(value: 'ml', child: Text('Milliliter (ml)')),
                  ],
                  onChanged: (value) {
                    _unitController.text = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a unit';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _stockQuantityController,
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
                  controller: _salePriceController,
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
                  value: _statusController.text,
                  decoration: const InputDecoration(labelText: 'Status *'),
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('Active')),
                    DropdownMenuItem(value: '1', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    _statusController.text = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _costController,
                  decoration: const InputDecoration(labelText: 'Cost'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _barcodeController,
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
              if (_formKey.currentState!.validate()) {
                if (product == null) {
                  // Add new product
                  final newProduct = Product(
                    name: _nameController.text,
                    unit: _unitController.text,
                    stockQuantity: double.parse(_stockQuantityController.text),
                    salePrice: double.parse(_salePriceController.text),
                    status: int.parse(_statusController.text),
                    cost: _costController.text.isNotEmpty ? double.parse(_costController.text) : null,
                    barcode: _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
                  );
                  await _productController.addProduct(newProduct);
                } else {
                  // Update existing product
                  final updatedProduct = Product(
                    id: product.id,
                    name: _nameController.text,
                    unit: _unitController.text,
                    stockQuantity: double.parse(_stockQuantityController.text),
                    salePrice: double.parse(_salePriceController.text),
                    status: int.parse(_statusController.text),
                    cost: _costController.text.isNotEmpty ? double.parse(_costController.text) : null,
                    barcode: _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
                    lastModified: product.lastModified,
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
}