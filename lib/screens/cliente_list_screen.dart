// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../controllers/cliente_controller.dart';
import '../models/client.dart';
import '../utils/format_utils.dart';
import '../widgets/custom_text_field.dart';

class ClienteListScreen extends StatefulWidget {
  const ClienteListScreen({Key? key}) : super(key: key);

  @override
  _ClienteListScreenState createState() => _ClienteListScreenState();
}

class _ClienteListScreenState extends State<ClienteListScreen> {
  final ClienteController _controller = ClienteController();
  List<Client> _clientes = [];
  bool _isLoading = true;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() {
      _isLoading = true;
    });

    final clientes = await _controller.getAll();

    setState(() {
      _clientes = clientes;
      _isLoading = false;
    });
  }

  List<Client> get _filteredClientes {
    if (_searchTerm.isEmpty) {
      return _clientes;
    }
    final term = _searchTerm.toLowerCase();
    return _clientes.where((cliente) {
      return cliente.name.toLowerCase().contains(term) ||
          cliente.cpfCnpj.contains(term);
    }).toList();
  }

  void _showClienteForm({Client? cliente}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: cliente?.name ?? '');
    final cpfCnpjController = TextEditingController(text: cliente?.cpfCnpj ?? '');
    final emailController = TextEditingController(text: cliente?.email ?? '');
    final phoneController = TextEditingController(text: cliente?.phone ?? '');
    final zipCodeController = TextEditingController(text: cliente?.zipCode ?? '');
    final addressController = TextEditingController(text: cliente?.address ?? '');
    final neighborhoodController = TextEditingController(text: cliente?.neighborhood ?? '');
    final cityController = TextEditingController(text: cliente?.city ?? '');
    final stateController = TextEditingController(text: cliente?.state ?? '');
    final bool isEditing = cliente != null;
    String selectedType = cliente?.type ?? 'F';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Nome',
                  controller: nameController,
                  isRequired: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const Text('Tipo: '),
                      Radio<String>(
                        value: 'F',
                        groupValue: selectedType,
                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                          });
                        },
                      ),
                      const Text('Físico'),
                      Radio<String>(
                        value: 'J',
                        groupValue: selectedType,
                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                          });
                        },
                      ),
                      const Text('Jurídico'),
                    ],
                  ),
                ),
                CustomTextField(
                  label: selectedType == 'F' ? 'CPF' : 'CNPJ',
                  controller: cpfCnpjController,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
                CustomTextField(
                  label: 'E-mail',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  label: 'Telefone',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                CustomTextField(
                  label: 'CEP',
                  controller: zipCodeController,
                  keyboardType: TextInputType.number,
                ),
                CustomTextField(
                  label: 'Endereço',
                  controller: addressController,
                ),
                CustomTextField(
                  label: 'Bairro',
                  controller: neighborhoodController,
                ),
                CustomTextField(
                  label: 'Cidade',
                  controller: cityController,
                ),
                CustomTextField(
                  label: 'Estado',
                  controller: stateController,
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
                final newCliente = Client(
                  id: cliente?.id,
                  name: nameController.text,
                  type: selectedType,
                  cpfCnpj: cpfCnpjController.text,
                  email: emailController.text.isNotEmpty ? emailController.text : null,
                  phone: phoneController.text.isNotEmpty ? phoneController.text : null,
                  zipCode: zipCodeController.text.isNotEmpty ? zipCodeController.text : null,
                  address: addressController.text.isNotEmpty ? addressController.text : null,
                  neighborhood: neighborhoodController.text.isNotEmpty ? neighborhoodController.text : null,
                  city: cityController.text.isNotEmpty ? cityController.text : null,
                  state: stateController.text.isNotEmpty ? stateController.text : null,
                  lastModified: DateTime.now().toIso8601String(),
                );

                bool success;
                if (isEditing) {
                  success = await _controller.update(newCliente);
                } else {
                  success = await _controller.add(newCliente);
                }

                Navigator.pop(context);

                if (success) {
                  _loadClientes();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Cliente ${isEditing ? 'atualizado' : 'adicionado'} com sucesso!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Erro ao ${isEditing ? 'atualizar' : 'adicionar'} cliente')),
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

  Future<void> _deleteCliente(Client cliente) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text(
                'Tem certeza que deseja excluir o cliente ${cliente.name}?'),
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
      final success = await _controller.delete(cliente.id!);

      if (success) {
        _loadClientes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente excluído com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir cliente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
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
                : _filteredClientes.isEmpty
                    ? const Center(child: Text('Nenhum cliente encontrado'))
                    : ListView.builder(
                        itemCount: _filteredClientes.length,
                        itemBuilder: (context, index) {
                          final cliente = _filteredClientes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(cliente.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${cliente.type == 'F' ? 'CPF' : 'CNPJ'}: ${FormatUtils.formatCpfCnpj(cliente.cpfCnpj)}'),
                                  if (cliente.phone != null)
                                    Text('Tel: ${FormatUtils.formatPhone(cliente.phone!)}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showClienteForm(cliente: cliente),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteCliente(cliente),
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
        onPressed: () => _showClienteForm(),
        tooltip: 'Adicionar Cliente',
        child: const Icon(Icons.add),
      ),
    );
  }
}