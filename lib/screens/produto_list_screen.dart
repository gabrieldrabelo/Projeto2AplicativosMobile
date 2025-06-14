// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../controllers/produto_controller.dart';
import '../models/product.dart';
import '../utils/format_utils.dart';
import '../widgets/custom_text_field.dart';

class ProdutoListScreen extends StatefulWidget {
  const ProdutoListScreen({Key? key}) : super(key: key);

  @override
  _ProdutoListScreenState createState() => _ProdutoListScreenState();
}

class _ProdutoListScreenState extends State<ProdutoListScreen> {
  final ProdutoController _controller = ProdutoController();
  List<Product> _produtos = [];
  bool _isLoading = true;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadProdutos();
  }

  Future<void> _loadProdutos() async {
    setState(() {
      _isLoading = true;
    });

    final produtos = await _controller.getAll();

    setState(() {
      _produtos = produtos;
      _isLoading = false;
    });
  }

  List<Product> get _filteredProdutos {
    if (_searchTerm.isEmpty) {
      return _produtos;
    }
    final term = _searchTerm.toLowerCase();
    return _produtos.where((produto) {
      return produto.name.toLowerCase().contains(term) ||
          produto.code.toLowerCase().contains(term);
    }).toList();
  }

  void _showProdutoForm({Product? produto}) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: produto?.code ?? '');
    final nameController = TextEditingController(text: produto?.name ?? '');
    final unitController = TextEditingController(text: produto?.unit ?? '');
    final priceController = TextEditingController(
        text: produto?.salePrice != null ? produto!.salePrice.toString() : '');
    final stockController = TextEditingController(
        text: produto?.stock != null ? produto!.stock.toString() : '');
    final descriptionController =
        TextEditingController(text: produto?.description ?? '');
    final bool isEditing = produto != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Produto' : 'Novo Produto'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Cu00f3digo',
                  controller: codeController,
                  isRequired: true,
                ),
                CustomTextField(
                  label: 'Nome',
                  controller: nameController,
                  isRequired: true,
                ),
                CustomTextField(
                  label: 'Unidade',
                  controller: unitController,
                  isRequired: true,
                ),
                CustomTextField(
                  label: 'Preu00e7o',
                  controller: priceController,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
                CustomTextField(
                  label: 'Estoque',
                  controller: stockController,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
                CustomTextField(
                  label: 'Descriu00e7u00e3o',
                  controller: descriptionController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newProduto = Product(
                  id: produto?.id,
                  code: codeController.text,
                  name: nameController.text,
                  unit: unitController.text,
                  salePrice: double.tryParse(priceController.text) ?? 0.0,
                  stock: double.tryParse(stockController.text) ?? 0.0,
                  description: descriptionController.text.isNotEmpty
                      ? descriptionController.text
                      : null,
                  lastModified: DateTime.now().toIso8601String(), stockQuantity: 0, status: 0,
                );

                bool success;
                if (isEditing) {
                  success = await _controller.update(newProduto);
                } else {
                  success = await _controller.add(newProduto);
                }

                Navigator.pop(context);

                if (success) {
                  _loadProdutos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Produto ${isEditing ? 'atualizado' : 'adicionado'} com sucesso!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Erro ao ${isEditing ? 'atualizar' : 'adicionar'} produto')),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduto(Product produto) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar exclusu00e3o'),
            content: Text(
                'Tem certeza que deseja excluir o produto ${produto.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      final success = await _controller.delete(produto.id!);

      if (success) {
        _loadProdutos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluu00eddo com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir produto')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquisar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProdutos.isEmpty
                    ? const Center(child: Text('Nenhum produto encontrado'))
                    : ListView.builder(
                        itemCount: _filteredProdutos.length,
                        itemBuilder: (context, index) {
                          final produto = _filteredProdutos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(produto.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cu00f3digo: ${produto.code}'),
                                  Text(
                                      'Preu00e7o: ${FormatUtils.formatCurrency(produto.salePrice)}'),
                                  Text(
                                      'Estoque: ${produto.stock} ${produto.unit}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showProdutoForm(produto: produto),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteProduto(produto),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProdutoForm(),
        tooltip: 'Adicionar Produto',
        child: const Icon(Icons.add),
      ),
    );
  }
}