import 'dart:convert';

class Product {
  int? id;
  String name;
  int quantity;
  double price;
  String? imagePath;
  String category;
  String status; // <-- added status

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.imagePath,
    required this.category,
    required this.status, // <-- include in constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imagePath': imagePath,
      'category': category,
      'status': status, // <-- include in map
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] as double? ?? 0.0),
      imagePath: map['imagePath'] as String?,
      category: (map['category'] as String?) ?? '',
      status: (map['status'] as String?) ?? '', // <-- parse status
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));
}

final List<Product> sampleProducts = [
  Product(
    id: 1,
    name: 'Red Apple',
    imagePath:
        'https://images.unsplash.com/photo-1630563451961-ac2ff27616ab?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=687',
    quantity: 25,
    price: 0.99,
    category: 'Fruits',
    status: 'available',
  ),
  Product(
    id: 2,
    name: 'Banana Bunch',
    imagePath:
        'https://images.unsplash.com/photo-1630563451961-ac2ff27616ab?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=687',
    quantity: 15,
    price: 1.50,
    category: 'Fruits',
    status: 'available',
  ),
  Product(
    id: 3,
    name: 'Orange Juice',
    imagePath:
        'https://images.unsplash.com/photo-1630563451961-ac2ff27616ab?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=687',
    quantity: 20,
    price: 2.75,
    category: 'Beverages',
    status: 'available',
  ),
  Product(
    id: 4,
    name: 'Dish Soap',
    imagePath:
        'https://images.unsplash.com/photo-1630563451961-ac2ff27616ab?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=687',
    quantity: 18,
    price: 3.20,
    category: 'Household',
    status: 'low', // example low stock
  ),
];
