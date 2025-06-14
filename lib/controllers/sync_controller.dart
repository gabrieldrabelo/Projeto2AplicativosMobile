import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../controllers/user_controller.dart';
import '../controllers/client_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/configuration_controller.dart';

class SyncController {
  final UserController _userController = UserController();
  final ClientController _clientController = ClientController();
  final ProductController _productController = ProductController();
  final OrderController _orderController = OrderController();
  final ConfigurationController _configController = ConfigurationController();

  // Structure to hold sync errors
  Map<String, List<Map<String, dynamic>>> syncErrors = {
    'users': [],
    'clients': [],
    'products': [],
    'orders': [],
  };

  // Clear previous errors
  void clearErrors() {
    syncErrors = {
      'users': [],
      'clients': [],
      'products': [],
      'orders': [],
    };
  }

  // Get server URL from configuration
  Future<String> getServerUrl() async {
    final config = await _configController.getConfiguration();
    return config?.serverUrl ?? 'http://localhost:8080';
  }

  // Sync users
  Future<bool> syncUsers() async {
    try {
      final serverUrl = await getServerUrl();
      final response = await http.get(Uri.parse('$serverUrl/usuarios'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['dados'] != null) {
          final serverUsers = List<User>.from(
              data['dados'].map((user) => User.fromJson(user)));
          
          // Get local users
          final localUsers = await _userController.getUsers();
          
          // Update local users with server data
          for (var serverUser in serverUsers) {
            final localUser = localUsers.firstWhere(
              (user) => user.id == serverUser.id,
              orElse: () => User(id: -1, name: '', password: ''),
            );
            
            if (localUser.id == -1) {
              // New user from server
              await _userController.addUser(serverUser);
            } else {
              // Check if server version is newer
              if (serverUser.lastModified != null && localUser.lastModified != null) {
                final serverDate = DateTime.parse(serverUser.lastModified!);
                final localDate = DateTime.parse(localUser.lastModified!);
                
                if (serverDate.isAfter(localDate)) {
                  await _userController.updateUser(serverUser);
                }
              }
            }
          }
          
          // Send local users to server
          for (var localUser in localUsers) {
            if (localUser.lastModified == null) {
              // This is a new local user, send to server
              try {
                final postResponse = await http.post(
                  Uri.parse('$serverUrl/usuarios'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(localUser.toJson()),
                );
                
                if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
                  // Update lastModified
                  localUser.lastModified = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
                  await _userController.updateUser(localUser);
                } else {
                  syncErrors['users']!.add({
                    'id': localUser.id,
                    'error': 'Failed to send to server: ${postResponse.statusCode}',
                  });
                }
              } catch (e) {
                syncErrors['users']!.add({
                  'id': localUser.id,
                  'error': 'Exception: $e',
                });
              }
            }
          }
          
          return true;
        }
      }
      
      syncErrors['users']!.add({
        'id': 0,
        'error': 'Failed to get users from server: ${response.statusCode}',
      });
      return false;
    } catch (e) {
      syncErrors['users']!.add({
        'id': 0,
        'error': 'Exception: $e',
      });
      return false;
    }
  }

  // Sync clients
  Future<bool> syncClients() async {
    try {
      final serverUrl = await getServerUrl();
      final response = await http.get(Uri.parse('$serverUrl/clientes'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['dados'] != null) {
          final serverClients = List<Client>.from(
              data['dados'].map((client) => Client.fromJson(client)));
          
          // Get local clients
          final localClients = await _clientController.getClients();
          
          // Update local clients with server data
          for (var serverClient in serverClients) {
            final localClient = localClients.firstWhere(
              (client) => client.id == serverClient.id,
              orElse: () => Client(id: -1, name: '', type: '', cpfCnpj: ''),
            );
            
            if (localClient.id == -1) {
              // New client from server
              await _clientController.addClient(serverClient);
            } else {
              // Check if server version is newer
              if (serverClient.lastModified != null && localClient.lastModified != null) {
                final serverDate = DateTime.parse(serverClient.lastModified!);
                final localDate = DateTime.parse(localClient.lastModified!);
                
                if (serverDate.isAfter(localDate)) {
                  await _clientController.updateClient(serverClient);
                }
              }
            }
          }
          
          // Send local clients to server
          for (var localClient in localClients) {
            if (localClient.lastModified == null) {
              // This is a new local client, send to server
              try {
                final postResponse = await http.post(
                  Uri.parse('$serverUrl/clientes'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(localClient.toJson()),
                );
                
                if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
                  // Update lastModified
                  localClient.lastModified = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
                  await _clientController.updateClient(localClient);
                } else {
                  syncErrors['clients']!.add({
                    'id': localClient.id,
                    'error': 'Failed to send to server: ${postResponse.statusCode}',
                  });
                }
              } catch (e) {
                syncErrors['clients']!.add({
                  'id': localClient.id,
                  'error': 'Exception: $e',
                });
              }
            }
          }
          
          return true;
        }
      }
      
      syncErrors['clients']!.add({
        'id': 0,
        'error': 'Failed to get clients from server: ${response.statusCode}',
      });
      return false;
    } catch (e) {
      syncErrors['clients']!.add({
        'id': 0,
        'error': 'Exception: $e',
      });
      return false;
    }
  }

  // Sync products
  Future<bool> syncProducts() async {
    try {
      final serverUrl = await getServerUrl();
      final response = await http.get(Uri.parse('$serverUrl/produtos'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['dados'] != null) {
          final serverProducts = List<Product>.from(
              data['dados'].map((product) => Product.fromJson(product)));
          
          // Get local products
          final localProducts = await _productController.getProducts();
          
          // Update local products with server data
          for (var serverProduct in serverProducts) {
            final localProduct = localProducts.firstWhere(
              (product) => product.id == serverProduct.id,
              orElse: () => Product(
                id: -1, 
                code: '', 
                name: '', 
                unit: '', 
                stock: 0, 
                salePrice: 0, stockQuantity: 0, status: 0
              ),
            );
            
            if (localProduct.id == -1) {
              // New product from server
              await _productController.addProduct(serverProduct);
            } else {
              // Check if server version is newer
              if (serverProduct.lastModified != null && localProduct.lastModified != null) {
                final serverDate = DateTime.parse(serverProduct.lastModified!);
                final localDate = DateTime.parse(localProduct.lastModified!);
                
                if (serverDate.isAfter(localDate)) {
                  await _productController.updateProduct(serverProduct);
                }
              }
            }
          }
          
          // Send local products to server
          for (var localProduct in localProducts) {
            if (localProduct.lastModified == null) {
              // This is a new local product, send to server
              try {
                final postResponse = await http.post(
                  Uri.parse('$serverUrl/produtos'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(localProduct.toJson()),
                );
                
                if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
                  // Update lastModified
                  localProduct.lastModified = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
                  await _productController.updateProduct(localProduct);
                } else {
                  syncErrors['products']!.add({
                    'id': localProduct.id,
                    'error': 'Failed to send to server: ${postResponse.statusCode}',
                  });
                }
              } catch (e) {
                syncErrors['products']!.add({
                  'id': localProduct.id,
                  'error': 'Exception: $e',
                });
              }
            }
          }
          
          return true;
        }
      }
      
      syncErrors['products']!.add({
        'id': 0,
        'error': 'Failed to get products from server: ${response.statusCode}',
      });
      return false;
    } catch (e) {
      syncErrors['products']!.add({
        'id': 0,
        'error': 'Exception: $e',
      });
      return false;
    }
  }

  // Sync orders
  Future<bool> syncOrders() async {
    try {
      final serverUrl = await getServerUrl();
      final response = await http.get(Uri.parse('$serverUrl/pedidos'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['dados'] != null) {
          final serverOrders = List<Order>.from(
              data['dados'].map((order) => Order.fromJson(order)));
          
          // Get local orders
          final localOrders = await _orderController.getOrders();
          
          // Update local orders with server data
          for (var serverOrder in serverOrders) {
            final localOrder = localOrders.firstWhere(
              (order) => order.id == serverOrder.id,
              orElse: () => Order(id: -1, clientId: 0, userId: 0, totalOrder: 0, creationDate: ''),
            );
            
            if (localOrder.id == -1) {
              // New order from server
              await _orderController.addOrder(serverOrder);
            } else {
              // Check if server version is newer
              if (serverOrder.lastModified != null && localOrder.lastModified != null) {
                final serverDate = DateTime.parse(serverOrder.lastModified!);
                final localDate = DateTime.parse(localOrder.lastModified!);
                
                if (serverDate.isAfter(localDate)) {
                  await _orderController.updateOrder(serverOrder);
                }
              }
            }
          }
          
          // Send local orders to server
          for (var localOrder in localOrders) {
            if (localOrder.lastModified == null) {
              // This is a new local order, send to server
              try {
                final postResponse = await http.post(
                  Uri.parse('$serverUrl/pedidos'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(localOrder.toJson()),
                );
                
                if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
                  // Update lastModified
                  localOrder.lastModified = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
                  await _orderController.updateOrder(localOrder);
                } else {
                  syncErrors['orders']!.add({
                    'id': localOrder.id,
                    'error': 'Failed to send to server: ${postResponse.statusCode}',
                  });
                }
              } catch (e) {
                syncErrors['orders']!.add({
                  'id': localOrder.id,
                  'error': 'Exception: $e',
                });
              }
            }
          }
          
          return true;
        }
      }
      
      syncErrors['orders']!.add({
        'id': 0,
        'error': 'Failed to get orders from server: ${response.statusCode}',
      });
      return false;
    } catch (e) {
      syncErrors['orders']!.add({
        'id': 0,
        'error': 'Exception: $e',
      });
      return false;
    }
  }

  // Sync all data
  Future<bool> syncAll() async {
    clearErrors();
    
    bool usersSuccess = await syncUsers();
    bool clientsSuccess = await syncClients();
    bool productsSuccess = await syncProducts();
    bool ordersSuccess = await syncOrders();
    
    return usersSuccess && clientsSuccess && productsSuccess && ordersSuccess;
  }
}