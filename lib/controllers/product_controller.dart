import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../utils/logger.dart';

class ProductController {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Product>> getProducts() async {
    final maps = await dbHelper.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProductById(int id) async {
    final maps = await dbHelper.query('products', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<int> addProduct(Product product) async {
    return await dbHelper.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    // Update lastModified timestamp
    product.lastModified = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    
    return await dbHelper.update(
      'products',
      product.toMap(),
      'id = ?',
      [product.id!],
    );
  }

  Future<int> deleteProduct(int id) async {
    return await dbHelper.delete('products', 'id = ?', [id]);
  }
}