import 'dart:io';

import 'package:get/get.dart';
import '../models/product_model.dart';
import 'package:storekeeper/services/db_service.dart'; // adjust path if needed

class ProductController extends GetxController {
  final products = <Product>[].obs;
  final DBService _db = DBService();

  @override
  void onInit() {
    super.onInit();
    loadProducts(); // load from DB at startup
  }

  final selected = Rxn<Product>();

  // Load products from DB and update the reactive list
  Future<List<Product>> loadProducts() async {
    try {
      final list = await _db
          .getProducts(); // calls your getProducts() DB function
      products.assignAll(list);
      return list;
    } catch (e) {
      // handle/log error as needed
      return <Product>[];
    }
  }

  // Create product using your DB function and update reactive list
  Future<Product?> createProduct({
    required String name,
    required String imagePath,
    required int quantity,
    required double price,
    required String category,
    required String status,
  }) async {
    try {
      final created = await _db.addProduct(
        name: name,
        imagePath: imagePath,
        quantity: quantity,
        price: price,
        category: category,
        status: status,
      );
      products.add(created);
      return created;
    } catch (e) {
      return null;
    }
  }

  void updateProduct(int index, Product p) {
    if (index >= 0 && index < products.length) products[index] = p;
  }

  /// Update a product in the DB and in-memory list. Returns true if update succeeded.
  Future<bool> updateProductInDb(Product p) async {
    try {
      final result = await _db.updateProduct(p);
      if (result > 0) {
        final idx = products.indexWhere((element) => element.id == p.id);
        if (idx != -1) {
          products[idx] = p;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete a product at [index] from both in-memory list and database (if id exists).
  Future<void> deleteProductAt(int index) async {
    if (index < 0 || index >= products.length) return;
    final prod = products[index];
    final id = prod.id;

    // Remove from in-memory list immediately to update UI
    products.removeAt(index);

    // Delete from DB if it has an id
    if (id != null) {
      try {
        await _db.deleteProduct(id);
      } catch (_) {
        // ignore DB errors for now; UI already updated
      }
    }
  }
}
