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
      version: 9, // Incrementado para versão 8 para adicionar coluna description na tabela products
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
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        stockQuantity REAL NOT NULL,
        salePrice REAL NOT NULL,
        stock INTEGER NOT NULL,
        status INTEGER NOT NULL,
        cost REAL,
        barcode TEXT,
        lastModified TEXT,
        description TEXT
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
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'draft',
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
        productName TEXT,
        price REAL NOT NULL DEFAULT 0.0,
        unit TEXT NOT NULL DEFAULT 'un',
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
        paymentType TEXT NOT NULL DEFAULT 'Dinheiro',
        description TEXT,
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
      if (oldVersion == 1 && newVersion >= 2) {
        // Add new columns to orders table
        await db.execute('ALTER TABLE orders ADD COLUMN notes TEXT');
        await db.execute('ALTER TABLE orders ADD COLUMN status TEXT NOT NULL DEFAULT \'draft\'');

        // Add new columns to order_items table
        await db.execute('ALTER TABLE order_items ADD COLUMN productName TEXT');
        await db.execute('ALTER TABLE order_items ADD COLUMN price REAL NOT NULL DEFAULT 0.0');
        await db.execute('ALTER TABLE order_items ADD COLUMN unit TEXT NOT NULL DEFAULT \'un\'');

        // Add new columns to order_payments table
        await db.execute('ALTER TABLE order_payments ADD COLUMN paymentType TEXT NOT NULL DEFAULT \'Dinheiro\'');
        await db.execute('ALTER TABLE order_payments ADD COLUMN description TEXT');
      }

      if (oldVersion == 2 && newVersion >= 3) {
        // Check if columns already exist before adding
        var columns = await db.rawQuery("PRAGMA table_info(products)");
        var columnNames = columns.map((c) => c['name'] as String).toList();
        if (!columnNames.contains('code')) {
          await db.execute('ALTER TABLE products ADD COLUMN description TEXT  \'\'');
        }
        if (!columnNames.contains('code')) {
          await db.execute('ALTER TABLE products ADD COLUMN code TEXT NOT NULL DEFAULT \'\'');
        }

        if (!columnNames.contains('status')) {
          await db.execute('ALTER TABLE products ADD COLUMN status INTEGER NOT NULL DEFAULT 1');
        }
      }

      if (oldVersion < 4 && newVersion >= 4) {
        // Add stock column if it does not exist
        var columns = await db.rawQuery("PRAGMA table_info(products)");
        var columnNames = columns.map((c) => c['name'] as String).toList();
        if (!columnNames.contains('stock')) {
          await db.execute('ALTER TABLE products ADD COLUMN stock INTEGER NOT NULL DEFAULT 0');
        }
      }
      if (oldVersion < 5 && newVersion >= 5) {
        // Add description column if it does not exist
        var columns = await db.rawQuery("PRAGMA table_info(products)");
        var columnNames = columns.map((c) => c['name'] as String).toList();
        if (!columnNames.contains('description')) {
          await db.execute('ALTER TABLE products ADD COLUMN description TEXT');
        }
      }


      if (oldVersion == 3 && newVersion >= 4) {
        // Add stock column to products table if it does not exist
        var columns = await db.rawQuery("PRAGMA table_info(products)");
        var columnNames = columns.map((c) => c['name'] as String).toList();

        if (!columnNames.contains('stock')) {
          await db.execute('ALTER TABLE products ADD COLUMN stock INTEGER NOT NULL DEFAULT 0');
        }
      }
    }
  }

  // Generic methods for CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    if (table == 'products' && !data.containsKey('stock')) {
      data['stock'] = 0;
    }
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