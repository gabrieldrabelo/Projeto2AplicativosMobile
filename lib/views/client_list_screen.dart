import 'package:flutter/material.dart';
import '../controllers/client_controller.dart';
import '../models/client.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({Key? key}) : super(key: key);

  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final ClientController _clientController = ClientController();
  List<Client> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
    });

    final clients = await _clientController.getClients();
    setState(() {
      _clients = clients;
      _isLoading = false;
    });
  }

  void _showClientForm({Client? client}) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: client?.name ?? '');
    final _typeController = TextEditingController(text: client?.type ?? 'F');
    final _cpfCnpjController = TextEditingController(text: client?.cpfCnpj ?? '');
    final _emailController = TextEditingController(text: client?.email ?? '');
    final _phoneController = TextEditingController(text: client?.phone ?? '');
    final _zipCodeController = TextEditingController(text: client?.zipCode ?? '');
    final _addressController = TextEditingController(text: client?.address ?? '');
    final _neighborhoodController = TextEditingController(text: client?.neighborhood ?? '');
    final _cityController = TextEditingController(text: client?.city ?? '');
    final _stateController = TextEditingController(text: client?.state ?? '');
    bool _isSearchingZipCode = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(client == null ? 'Add Client' : 'Edit Client'),
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
                    value: _typeController.text,
                    decoration: const InputDecoration(labelText: 'Type *'),
                    items: const [
                      DropdownMenuItem(value: 'F', child: Text('Physical (F)')),
                      DropdownMenuItem(value: 'J', child: Text('Legal (J)')),
                    ],
                    onChanged: (value) {
                      _typeController.text = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a type';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _cpfCnpjController,
                    decoration: const InputDecoration(labelText: 'CPF/CNPJ *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter CPF/CNPJ';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _zipCodeController,
                          decoration: const InputDecoration(labelText: 'ZIP Code'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isSearchingZipCode
                          ? const CircularProgressIndicator()
                          : IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () async {
                                if (_zipCodeController.text.isNotEmpty) {
                                  setState(() {
                                    _isSearchingZipCode = true;
                                  });
                                  
                                  final address = await _clientController.searchAddressByZipCode(_zipCodeController.text);
                                  
                                  setState(() {
                                    _isSearchingZipCode = false;
                                  });
                                  
                                  if (address != null) {
                                    _addressController.text = address['address'] ?? '';
                                    _neighborhoodController.text = address['neighborhood'] ?? '';
                                    _cityController.text = address['city'] ?? '';
                                    _stateController.text = address['state'] ?? '';
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Address found!')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Address not found')),
                                    );
                                  }
                                }
                              },
                            ),
                    ],
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextFormField(
                    controller: _neighborhoodController,
                    decoration: const InputDecoration(labelText: 'Neighborhood'),
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(labelText: 'State'),
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
                  if (client == null) {
                    // Add new client
                    final newClient = Client(
                      name: _nameController.text,
                      type: _typeController.text,
                      cpfCnpj: _cpfCnpjController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      zipCode: _zipCodeController.text,
                      address: _addressController.text,
                      neighborhood: _neighborhoodController.text,
                      city: _cityController.text,
                      state: _stateController.text,
                    );
                    await _clientController.addClient(newClient);
                  } else {
                    // Update existing client
                    final updatedClient = Client(
                      id: client.id,
                      name: _nameController.text,
                      type: _typeController.text,
                      cpfCnpj: _cpfCnpjController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      zipCode: _zipCodeController.text,
                      address: _addressController.text,
                      neighborhood: _neighborhoodController.text,
                      city: _cityController.text,
                      state: _stateController.text,
                      lastModified: client.lastModified,
                    );
                    await _clientController.updateClient(updatedClient);
                  }
                  Navigator.pop(context);
                  _loadClients();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${client.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _clientController.deleteClient(client.id!);
              Navigator.pop(context);
              _loadClients();
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
        title: const Text('Client Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clients.isEmpty
              ? const Center(child: Text('No clients found'))
              : ListView.builder(
                  itemCount: _clients.length,
                  itemBuilder: (context, index) {
                    final client = _clients[index];
                    return ListTile(
                      title: Text(client.name),
                      subtitle: Text('${client.type == 'F' ? 'Physical' : 'Legal'} - ${client.cpfCnpj}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showClientForm(client: client),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(client),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClientForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}