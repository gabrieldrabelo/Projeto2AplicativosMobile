import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sales_force.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        lastModified TEXT
      )
    ''');

    // Clients table
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        cpfCnpj TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        zipCode TEXT,
        address TEXT,
        neighborhood TEXT,
        city TEXT,
        state TEXT,
        lastModified TEXT
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        stockQuantity REAL NOT NULL,
        salePrice REAL NOT NULL,
        status INTEGER NOT NULL,
        cost REAL,
        barcode TEXT,
        lastModified TEXT
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        totalOrder REAL NOT NULL,
        creationDate TEXT NOT NULL,
        lastModified TEXT,
        FOREIGN KEY (clientId) REFERENCES clients (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Order Items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity REAL NOT NULL,
        totalItem REAL NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    // Order Payments table
    await db.execute('''
      CREATE TABLE order_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        value REAL NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');

    // Configuration table
    await db.execute('''
      CREATE TABLE configuration (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serverUrl TEXT,
        lastSync TEXT
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'name': 'admin',
      'password': 'admin',
    });

    // Insert default configuration
    await db.insert('configuration', {
      'serverUrl': 'http://localhost:8080',
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Add upgrade logic here if needed in the future
    }
  }

  // Generic methods for CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    final db = await instance.database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> update(String table, Map<String, dynamic> data, String where, List<dynamic> whereArgs) async {
    final db = await instance.database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await instance.database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}