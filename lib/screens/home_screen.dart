import 'package:flutter/material.dart';
import 'cliente_list_screen.dart';
import 'produto_list_screen.dart';
import 'usuario_list_screen.dart';
import '../views/order_form_screen.dart';
import '../views/configuration_screen.dart';
import '../views/sync_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Force App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              context,
              'Clientes',
              Icons.people,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClienteListScreen(),
                ),
              ),
            ),
            _buildMenuCard(
              context,
              'Produtos',
              Icons.inventory,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProdutoListScreen(),
                ),
              ),
            ),
            _buildMenuCard(
              context,
              'Pedidos',
              Icons.shopping_cart,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderFormScreen(),
                ),
              ),
            ),
            _buildMenuCard(
              context,
              'Usuários',
              Icons.person,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UsuarioListScreen(),
                ),
              ),
            ),
            _buildMenuCard(
              context,
              'Configuração',
              Icons.settings,
              Colors.grey,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfigurationScreen(),
                ),
              ),
            ),
            _buildMenuCard(
              context,
              'Sincronização',
              Icons.sync,
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SyncScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  