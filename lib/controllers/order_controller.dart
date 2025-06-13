import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/order_payment.dart';

class OrderController {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Order>> getOrders() async {
    final db = await dbHelper.database;

    // Get all orders
    final orderMaps = await dbHelper.query('orders');
    List<Order> orders = [];

    // For each order, get its items and payments
    for (var orderMap in orderMaps) {
      final orderId = orderMap['id'] as int;

      // Get items for this order
      final itemMaps = await db.query(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [orderId],
      );
      final items = itemMaps.map((map) => OrderItem.fromMap(map)).toList();

      // Get payments for this order
      final paymentMaps = await db.query(
        'order_payments',
        where: 'orderId = ?',
        whereArgs: [orderId],
      );
      final payments =
          paymentMaps.map((map) => OrderPayment.fromMap(map)).toList();

      // Create the order with its items and payments
      final order = Order.fromMap(orderMap);
      order.items = items;
      order.payments = payments;

      orders.add(order);
    }

    return orders;
  }

  Future<Order?> getOrderById(int id) async {
    final db = await dbHelper.database;

    // Get the order
    final orderMaps =
        await dbHelper.query('orders', where: 'id = ?', whereArgs: [id]);
    if (orderMaps.isEmpty) {
      return null;
    }

    final orderMap = orderMaps.first;
    final orderId = orderMap['id'] as int;

    // Get items for this order
    final itemMaps = await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    final items = itemMaps.map((map) => OrderItem.fromMap(map)).toList();

    // Get payments for this order
    final paymentMaps = await db.query(
      'order_payments',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    final payments =
        paymentMaps.map((map) => OrderPayment.fromMap(map)).toList();

    // Create the order with its items and payments
    final order = Order.fromMap(orderMap);
    order.items = items;
    order.payments = payments;

    return order;
  }

  Future<int> addOrder(Order order, List<OrderItem> orderItems,
      List<OrderPayment> orderPayments) async {
    final db = await dbHelper.database;

    // Set creation date if not set
    if (order.creationDate.isEmpty) {
      order.creationDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    }

    // Start a transaction
    return await db.transaction((txn) async {
      // Insert the order
      final orderId = await txn.insert('orders', order.toMap());

      // Insert all items
      for (var item in order.items) {
        item.orderId = orderId;
        await txn.insert('order_items', item.toMap());
      }

      // Insert all payments
      for (var payment in order.payments) {
        payment.orderId = orderId;
        await txn.insert('order_payments', payment.toMap());
      }

      return orderId;
    });
  }

  Future<int> updateOrder(Order order, List<OrderItem> orderItems,
      List<OrderPayment> orderPayments) async {
    final db = await dbHelper.database;

    // Update lastModified timestamp
    order.lastModified =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Start a transaction
    return await db.transaction((txn) async {
      // Update the order
      await txn.update(
        'orders',
        order.toMap(),
        where: 'id = ?',
        whereArgs: [order.id],
      );

      // Delete all existing items and payments
      await txn.delete(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [order.id],
      );

      await txn.delete(
        'order_payments',
        where: 'orderId = ?',
        whereArgs: [order.id],
      );

      // Insert all items
      for (var item in order.items) {
        item.orderId = order.id!;
        await txn.insert('order_items', item.toMap());
      }

      // Insert all payments
      for (var payment in order.payments) {
        payment.orderId = order.id!;
        await txn.insert('order_payments', payment.toMap());
      }

      return order.id!;
    });
  }

  Future<int> deleteOrder(int id) async {
    // The foreign key constraints with CASCADE will automatically delete related items and payments
    return await dbHelper.delete('orders', 'id = ?', [id]);
  }

  // Validate if the order is valid (has at least one item and one payment, and totals match)
  bool validateOrder(Order order) {
    if (order.items.isEmpty || order.payments.isEmpty) {
      return false;
    }

    // Calculate total from items
    double itemsTotal = 0;
    for (var item in order.items) {
      itemsTotal += item.totalItem;
    }

    // Calculate total from payments
    double paymentsTotal = 0;
    for (var payment in order.payments) {
      paymentsTotal += payment.value;
    }

    // Check if totals match (with a small tolerance for floating point errors)
    return (itemsTotal - paymentsTotal).abs() < 0.01;
  }

  getOrderItems(int i) {}

  getOrderPayments(int i) {}
}
