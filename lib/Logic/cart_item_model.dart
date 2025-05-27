import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String imagePath;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['images'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'images': imagePath,
      'quantity': quantity,
    };
  }
}

class CartModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CartItem>> getCartItems() {
    return _firestore.collection('cart').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList());
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await _firestore.collection('cart').doc(itemId).delete();
    } else {
      await _firestore
          .collection('cart')
          .doc(itemId)
          .update({'quantity': newQuantity});
    }
  }

  Future<void> removeItem(String itemId) async {
    await _firestore.collection('cart').doc(itemId).delete();
  }

  Future<void> toggleSelectAll(bool selectAll) async {
    final snapshot = await _firestore.collection('cart').get();
    if (selectAll) {
      for (var doc in snapshot.docs) {
        await doc.reference.update({'quantity': 1});
      }
    } else {
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  double calculateTotalPrice(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  int calculateTotalItems(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<void> checkout(List<CartItem> items) async {
    if (items.isEmpty) return;

    final batch = _firestore.batch();
    final ordersRef = _firestore.collection('orders').doc();

    batch.set(ordersRef, {
      'date': DateTime.now(),
      'items': items.map((item) => item.toMap()).toList(),
      'total': calculateTotalPrice(items),
    });

    for (var item in items) {
      batch.delete(_firestore.collection('cart').doc(item.id));
    }

    await batch.commit();
  }
}