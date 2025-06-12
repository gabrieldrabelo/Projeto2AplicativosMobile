import 'package:sqflite/sqflite.dart';
import '../controllers/product_controller.dart';
import '../controllers/client_controller.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/order_payment.dart';
import 'database_helper.dart';

class MigrationHelper {
  final dbHelper = DatabaseHelper.instance;
  final ProductController _productController = ProductController();
  final ClientController _clientController = ClientController();

  // Método para atualizar os dados após a migração do banco de dados
  Future<void> updateDataAfterMigration() async {
    await _updateOrderItems();
    await _updateOrderPayments();
    await _updateOrders();
  }

  // Atualiza os itens de pedido com informações do produto
  Future<void> _updateOrderItems() async {
    final db = await dbHelper.database;
    
    // Buscar todos os itens de pedido
    final itemMaps = await db.query('order_items');
    
    // Para cada item, buscar o produto correspondente e atualizar os campos
    for (var itemMap in itemMaps) {
      final item = OrderItem.fromMap(itemMap);
      final product = await _productController.getProductById(item.productId);
      
      if (product != null) {
        // Atualizar o item com os dados do produto
        await db.update(
          'order_items',
          {
            'productName': product.name,
            'price': product.salePrice,
            'unit': product.unit,
          },
          where: 'id = ?',
          whereArgs: [item.id],
        );
      }
    }
  }

  // Atualiza os pagamentos com tipo padrão
  Future<void> _updateOrderPayments() async {
    final db = await dbHelper.database;
    
    // Buscar todos os pagamentos
    final paymentMaps = await db.query('order_payments');
    
    // Para cada pagamento, definir o tipo padrão se não estiver definido
    for (var paymentMap in paymentMaps) {
      final payment = OrderPayment.fromMap(paymentMap);
      
      // Verificar se o tipo de pagamento já está definido
      if (paymentMap['paymentType'] == null) {
        await db.update(
          'order_payments',
          {'paymentType': 'Dinheiro'},
          where: 'id = ?',
          whereArgs: [payment.id],
        );
      }
    }
  }

  // Atualiza os pedidos com nome do cliente
  Future<void> _updateOrders() async {
    final db = await dbHelper.database;
    
    // Buscar todos os pedidos
    final orderMaps = await db.query('orders');
    
    // Para cada pedido, buscar o cliente correspondente e atualizar o status
    for (var orderMap in orderMaps) {
      final order = Order.fromMap(orderMap);
      
      // Definir status padrão se não estiver definido
      if (orderMap['status'] == null) {
        await db.update(
          'orders',
          {'status': 'confirmed'}, // Assumimos que pedidos existentes já estão confirmados
          where: 'id = ?',
          whereArgs: [order.id],
        );
      }
    }
  }
}