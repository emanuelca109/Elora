import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('elora_database.db');
    return _database!;
  }

  static void initializePlatform() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> _initDB(String filePath) async {
    initializePlatform();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        presentation TEXT NOT NULL,
        origin TEXT NOT NULL,
        variety TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        description TEXT NOT NULL,
        image_url TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_name TEXT NOT NULL,
        client_phone TEXT NOT NULL,
        client_email TEXT NOT NULL,
        delivery_address TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        total REAL NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        presentation TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        title TEXT NOT NULL,
        recipient_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address_line TEXT NOT NULL,
        city TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_favorites (
        user_email TEXT NOT NULL,
        product_id INTEGER NOT NULL,
        PRIMARY KEY (user_email, product_id)
      )
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    for (final user in SeedData.initialUsers) {
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (final product in SeedData.initialProducts) {
      await db.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (final cat in ['Mujer', 'Hombre', 'Unisex', 'Sets']) {
      await db.insert(
        'categories',
        {'name': cat},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    if (count == null || count == 0) {
      for (final cat in ['Mujer', 'Hombre', 'Unisex', 'Sets']) {
        await db.insert('categories', {'name': cat},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    final maps = await db.query('categories', orderBy: 'id ASC');
    return maps.map((m) => m['name'] as String).toList();
  }

  Future<bool> insertCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final db = await database;
    try {
      await db.insert(
        'categories',
        {'name': trimmed},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateCategory(String oldName, String newName) async {
    final trimmedOld = oldName.trim();
    final trimmedNew = newName.trim();
    if (trimmedOld.isEmpty || trimmedNew.isEmpty) return false;
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.update(
          'categories',
          {'name': trimmedNew},
          where: 'LOWER(name) = ?',
          whereArgs: [trimmedOld.toLowerCase()],
        );
        await txn.update(
          'products',
          {'category': trimmedNew},
          where: 'LOWER(category) = ?',
          whereArgs: [trimmedOld.toLowerCase()],
        );
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCategory(String name, {String fallbackCategory = 'Unisex'}) async {
    final trimmed = name.trim();
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.delete(
          'categories',
          where: 'LOWER(name) = ?',
          whereArgs: [trimmed.toLowerCase()],
        );
        // Reasignar productos de la categoría eliminada a la categoría de respaldo
        await txn.update(
          'products',
          {'category': fallbackCategory},
          where: 'LOWER(category) = ?',
          whereArgs: [trimmed.toLowerCase()],
        );
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> seedInitialOrdersIfEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM orders'),
    );
    if (count == null || count == 0) {
      final now = DateTime.now();
      final order1Id = await db.insert('orders', {
        'client_name': 'Camila Restrepo',
        'client_phone': '3104567890',
        'client_email': 'cliente@elora.com',
        'delivery_address': 'Cl. 85 #12-40, El Retiro, Bogotá',
        'payment_method': 'Contraentrega',
        'total': 1350000.0,
        'created_at': now.subtract(const Duration(hours: 3)).toIso8601String(),
        'status': 'Preparando',
      });
      await db.insert('order_items', {
        'order_id': order1Id,
        'product_id': 1,
        'product_name': 'Baccarat Rouge 540',
        'presentation': '100 ml',
        'quantity': 1,
        'unit_price': 1350000.0,
      });

      final order2Id = await db.insert('orders', {
        'client_name': 'Mateo Gómez',
        'client_phone': '3209876543',
        'client_email': 'mateo@elora.com',
        'delivery_address': 'Cra 43A #1-50, Poblado, Medellín',
        'payment_method': 'Transferencia Bancaria',
        'total': 890000.0,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'status': 'En camino',
      });
      await db.insert('order_items', {
        'order_id': order2Id,
        'product_id': 3,
        'product_name': 'Aventus Cologne',
        'presentation': '100 ml',
        'quantity': 1,
        'unit_price': 890000.0,
      });

      final order3Id = await db.insert('orders', {
        'client_name': 'Valentina Silva',
        'client_phone': '3001234567',
        'client_email': 'valentina@elora.com',
        'delivery_address': 'Cra 7 #72-10, Rosales, Bogotá',
        'payment_method': 'Nequi / Tarjeta',
        'total': 1450000.0,
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'status': 'Entregado',
      });
      await db.insert('order_items', {
        'order_id': order3Id,
        'product_id': 2,
        'product_name': 'Lost Cherry',
        'presentation': '100 ml',
        'quantity': 1,
        'unit_price': 1450000.0,
      });
    }
  }

  Future<void> resyncSeedProducts() async {
    final db = await database;
    for (final product in SeedData.initialProducts) {
      final existing = await db.query(
        'products',
        where: 'name = ?',
        whereArgs: [product.name],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        final id = existing.first['id'] as int;
        await db.update(
          'products',
          product.copyWith(id: id).toMap(),
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        await db.insert('products', product.toMap());
      }
    }
  }

  // -------------------------------------------------------------
  // USER OPERATIONS
  // -------------------------------------------------------------

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> createUser(UserModel user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<bool> updateUserPassword(String email, String newPassword) async {
    final db = await database;
    final count = await db.update(
      'users',
      {'password': newPassword},
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    return count > 0;
  }

  // -------------------------------------------------------------
  // PRODUCT OPERATIONS
  // -------------------------------------------------------------

  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    var result = await db.query('products', orderBy: 'id DESC');
    if (result.isEmpty) {
      for (final product in SeedData.initialProducts) {
        await db.insert(
          'products',
          product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      result = await db.query('products', orderBy: 'id DESC');
    } else {
      // Sincronizar automáticamente nuevas fragancias exclusivas añadidas al catálogo
      bool insertedNew = false;
      for (final product in SeedData.initialProducts) {
        final existing = await db.query(
          'products',
          where: 'name = ?',
          whereArgs: [product.name],
          limit: 1,
        );
        if (existing.isEmpty) {
          await db.insert(
            'products',
            product.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
          insertedNew = true;
        }
      }
      if (insertedNew) {
        result = await db.query('products', orderBy: 'id DESC');
      }
    }
    return result.map((json) => ProductModel.fromMap(json)).toList();
  }

  Future<ProductModel?> getProductById(int id) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return ProductModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertProduct(ProductModel product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------------------------------------------------
  // ORDER OPERATIONS (ATOMIC TRANSACTION WITH STOCK DEDUCTION)
  // -------------------------------------------------------------

  Future<int> createOrder(OrderModel order) async {
    final db = await database;

    return await db.transaction<int>((txn) async {
      // 1. Insert order
      final orderId = await txn.insert(
        'orders',
        order.toMap(),
      );

      // 2. Insert items and decrement stock atomically
      for (final item in order.items) {
        await txn.insert(
          'order_items',
          item.toMap(explicitOrderId: orderId),
        );

        // Deduct stock validating availability
        final affectedRows = await txn.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?',
          [item.quantity, item.productId, item.quantity],
        );

        if (affectedRows == 0) {
          throw Exception(
            'Stock insuficiente para el producto "${item.productName}". Por favor ajusta tu pedido.',
          );
        }
      }

      return orderId;
    });
  }

  Future<List<OrderModel>> getAllOrders() async {
    await seedInitialOrdersIfEmpty();
    final db = await database;
    final orderMaps = await db.query('orders', orderBy: 'id DESC');

    final List<OrderModel> orders = [];
    for (final oMap in orderMaps) {
      final orderId = oMap['id'] as int;
      final itemMaps = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
      final items = itemMaps.map((i) => OrderItemModel.fromMap(i)).toList();
      orders.add(OrderModel.fromMap(oMap, items: items));
    }

    return orders;
  }

  Future<List<OrderModel>> getOrdersByEmail(String email) async {
    final db = await database;
    final orderMaps = await db.query(
      'orders',
      where: 'LOWER(client_email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      orderBy: 'id DESC',
    );

    final List<OrderModel> orders = [];
    for (final oMap in orderMaps) {
      final orderId = oMap['id'] as int;
      final itemMaps = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
      final items = itemMaps.map((i) => OrderItemModel.fromMap(i)).toList();
      orders.add(OrderModel.fromMap(oMap, items: items));
    }

    return orders;
  }

  Future<int> updateOrderStatus(int orderId, String newStatus) async {
    final db = await database;
    return await db.update(
      'orders',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  // --- GESTIÓN DE DIRECCIONES DE CLIENTE ---
  Future<void> _ensureAddressTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        title TEXT NOT NULL,
        recipient_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address_line TEXT NOT NULL,
        city TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getAddresses(String email) async {
    final db = await database;
    await _ensureAddressTable(db);
    final normalizedEmail = email.trim().toLowerCase();
    final maps = await db.query(
      'addresses',
      where: 'LOWER(user_email) = ?',
      whereArgs: [normalizedEmail],
      orderBy: 'is_default DESC, id DESC',
    );

    if (maps.isEmpty) {
      final defaultId = await db.insert('addresses', {
        'user_email': normalizedEmail,
        'title': 'Casa (Principal)',
        'recipient_name': 'Emanuel Gómez',
        'phone': '312 456 7890',
        'address_line': 'Cra 43A # 1-50, El Poblado',
        'city': 'Medellín, Antioquia',
        'is_default': 1,
      });
      return [
        {
          'id': defaultId,
          'user_email': normalizedEmail,
          'title': 'Casa (Principal)',
          'recipient_name': 'Emanuel Gómez',
          'phone': '312 456 7890',
          'address_line': 'Cra 43A # 1-50, El Poblado',
          'city': 'Medellín, Antioquia',
          'is_default': 1,
        }
      ];
    }
    return List<Map<String, dynamic>>.from(maps);
  }

  Future<int> insertAddress(Map<String, dynamic> address) async {
    final db = await database;
    await _ensureAddressTable(db);
    final email = (address['user_email'] as String).trim().toLowerCase();
    if (address['is_default'] == 1) {
      await db.update(
        'addresses',
        {'is_default': 0},
        where: 'LOWER(user_email) = ?',
        whereArgs: [email],
      );
    }
    final toInsert = Map<String, dynamic>.from(address);
    toInsert['user_email'] = email;
    return await db.insert('addresses', toInsert);
  }

  Future<int> updateAddress(int id, Map<String, dynamic> address) async {
    final db = await database;
    await _ensureAddressTable(db);
    if (address['is_default'] == 1 && address.containsKey('user_email')) {
      final email = (address['user_email'] as String).trim().toLowerCase();
      await db.update(
        'addresses',
        {'is_default': 0},
        where: 'LOWER(user_email) = ?',
        whereArgs: [email],
      );
    }
    return await db.update('addresses', address, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAddress(int id) async {
    final db = await database;
    await _ensureAddressTable(db);
    return await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setDefaultAddress(int id, String email) async {
    final db = await database;
    await _ensureAddressTable(db);
    final normalizedEmail = email.trim().toLowerCase();
    await db.update(
      'addresses',
      {'is_default': 0},
      where: 'LOWER(user_email) = ?',
      whereArgs: [normalizedEmail],
    );
    await db.update(
      'addresses',
      {'is_default': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _ensureFavoritesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_favorites (
        user_email TEXT NOT NULL,
        product_id INTEGER NOT NULL,
        PRIMARY KEY (user_email, product_id)
      )
    ''');
  }

  Future<List<int>> getFavorites(String userEmail) async {
    final db = await database;
    await _ensureFavoritesTable(db);
    final normalized = userEmail.trim().toLowerCase();
    final maps = await db.query(
      'user_favorites',
      columns: ['product_id'],
      where: 'LOWER(user_email) = ?',
      whereArgs: [normalized],
    );
    return maps.map((m) => m['product_id'] as int).toList();
  }

  Future<void> addFavorite(String userEmail, int productId) async {
    final db = await database;
    await _ensureFavoritesTable(db);
    final normalized = userEmail.trim().toLowerCase();
    await db.insert(
      'user_favorites',
      {
        'user_email': normalized,
        'product_id': productId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(String userEmail, int productId) async {
    final db = await database;
    await _ensureFavoritesTable(db);
    final normalized = userEmail.trim().toLowerCase();
    await db.delete(
      'user_favorites',
      where: 'LOWER(user_email) = ? AND product_id = ?',
      whereArgs: [normalized, productId],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
