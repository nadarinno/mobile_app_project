import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String imagePath;
  final String color;
  final String size;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.color,
    required this.size,
    required this.quantity,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['image'] ?? '',
      color: data['color'] ?? '',
      size: data['size'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'image': imagePath,
      'color': color,
      'size': size,
      'quantity': quantity,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}