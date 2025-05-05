import 'package:cloud_firestore/cloud_firestore.dart';

class Shop {
  final String id; // Add id property
  final String name;
  final bool active;
  final String ownerId;
  final DateTime createdAt;
  final Product product;

  // Constructor
  Shop({
    required this.id, // Add id parameter to constructor
    required this.name,
    required this.active,
    required this.ownerId,
    required this.createdAt,
    required this.product,
  });

  // Factory constructor to create a Shop instance from Firestore document data
  factory Shop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Shop(
      id: doc.id, // Set id from the document's ID
      name: data['name'] ?? '',
      active: data['active'] ?? true,
      ownerId: data['ownerId'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // or handle it differently
      product: Product.fromMap(data['product'] ?? {}),
    );
  }

  // Method to convert Shop instance to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'active': active,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'product': product.toMap(),
    };
  }
}

class Product {
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  Product({
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  // Factory constructor to create a Product instance from a map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0.0,
      imageUrl: map['imageUrl'],
    );
  }

  // Method to convert Product instance to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
