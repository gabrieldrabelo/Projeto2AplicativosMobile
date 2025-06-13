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
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: client?.name ?? '');
    final typeController = TextEditingController(text: client?.type ?? 'F');
    final cpfCnpjController = TextEditingController(text: client?.cpfCnpj ?? '');
    final emailController = TextEditingController(text: client?.email ?? '');
    final phoneController = TextEditingController(text: client?.phone ?? '');
    final zipCodeController = TextEditingController(text: client?.zipCode ?? '');
    final addressController = TextEditingController(text: client?.address ?? '');
    final neighborhoodController = TextEditingController(text: client?.neighborhood ?? '');
    final cityController = TextEditingController(text: client?.city ?? '');
    final stateController = TextEditingController(text: client?.state ?? '');
    bool isSearchingZipCode = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(client == null ? 'Add Client' : 'Edit Client'),
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
                    value: typeController.text,
                    decoration: const InputDecoration(labelText: 'Type *'),
                    items: const [
                      DropdownMenuItem(value: 'F', child: Text('Physical (F)')),
                      DropdownMenuItem(value: 'J', child: Text('Legal (J)')),
                    ],
                    onChanged: (value) {
                      typeController.text = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a type';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: cpfCnpjController,
                    decoration: const InputDecoration(labelText: 'CPF/CNPJ *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter CPF/CNPJ';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: zipCodeController,
                          decoration: const InputDecoration(labelText: 'ZIP Code'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      isSearchingZipCode
                          ? const CircularProgressIndicator()
                          : IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () async {
                                if (zipCodeController.text.isNotEmpty) {
                                  setState(() {
                                    isSearchingZipCode = true;
                                  });
                                  
                                  final address = await _clientController.searchAddressByZipCode(zipCodeController.text);
                                  
                                  setState(() {
                                    isSearchingZipCode = false;
                                  });
                                  
                                  if (address != null) {
                                    addressController.text = address['address'] ?? '';
                                    neighborhoodController.text = address['neighborhood'] ?? '';
                                    cityController.text = address['city'] ?? '';
                                    stateController.text = address['state'] ?? '';
                                    
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
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextFormField(
                    controller: neighborhoodController,
                    decoration: const InputDecoration(labelText: 'Neighborhood'),
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  TextFormField(
                    controller: stateController,
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
                if (formKey.currentState!.validate()) {
                  if (client == null) {
                    // Add new client
                    final newClient = Client(
                      name: nameController.text,
                      type: typeController.text,
                      cpfCnpj: cpfCnpjController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      zipCode: zipCodeController.text,
                      address: addressController.text,
                      neighborhood: neighborhoodController.text,
                      city: cityController.text,
                      state: stateController.text,
                    );
                    await _clientController.addClient(newClient);
                  } else {
                    // Update existing client
                    final updatedClient = Client(
                      id: client.id,
                      name: nameController.text,
                      type: typeController.text,
                      cpfCnpj: cpfCnpjController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      zipCode: zipCodeController.text,
                      address: addressController.text,
                      neighborhood: neighborhoodController.text,
                      city: cityController.text,
                      state: stateController.text,
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