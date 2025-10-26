// TODO: implement sqflite-based DB service
// This is a skeleton file showing expected methods to implement.

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../modules/product/models/product_model.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  final List<Product> _products = [];
  final StreamController<List<Product>> _productsStreamController =
      StreamController<List<Product>>.broadcast();

  Stream<List<Product>> get productsStream => _productsStreamController.stream;

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'storekeeper.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            quantity INTEGER,
            price REAL,
            imagePath TEXT,
            category TEXT,
            status TEXT
          )
        ''');
      },
    );
  }

  // CRUD: create
  Future<Product> addProduct({
    required String name,
    required String imagePath,
    required int quantity,
    required double price,
    required String category,
    required String status,
  }) async {
    final db = await database; // Your SQLite database instance

    // Create a new Product object
    final product = Product(
      name: name,
      imagePath: imagePath,
      quantity: quantity,
      price: price,
      category: category,
      status: status,
    );

    // Insert into the database
    final id = await db.insert('products', product.toMap());

    // Create the product object with the generated ID
    final createdProduct = Product(
      id: id,
      name: name,
      imagePath: imagePath,
      quantity: quantity,
      price: price,
      category: category,
      status: status,
    );

    // Add to local list & notify listeners (if using provider or streams)
    _products.add(createdProduct);
    _productsStreamController.add(_products);

    return createdProduct;
  }

  // CRUD: read
  Future<List<Product>> getProducts() async {
    final db = await database;
    final rows = await db.query('products');
    final products = rows.map((r) => Product.fromMap(r)).toList();

    // Update cache + emit to stream
    _products
      ..clear()
      ..addAll(products);
    _productsStreamController.add(List.from(_products));

    return products;
  }

  // UPDATE
  Future<int> updateProduct(Product p) async {
    final db = await database;
    final result = await db.update(
      'products',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );

    if (result > 0) {
      // Update local cache
      final index = _products.indexWhere((prod) => prod.id == p.id);
      if (index != -1) {
        _products[index] = p;
        _productsStreamController.add(List.from(_products)); // emit update
      }
    }
    return result;
  }

  // DELETE
  Future<int> deleteProduct(int id) async {
    final db = await database;
    final result = await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result > 0) {
      _products.removeWhere((p) => p.id == id);
      _productsStreamController.add(List.from(_products)); // emit update
    }
    return result;
  }

  // Close stream (important to avoid memory leaks)
  void dispose() {
    _productsStreamController.close();
  }
}
