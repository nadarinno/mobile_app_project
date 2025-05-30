import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_item_model.dart';

class CartModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<CartItem>> getCartItems() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList());
  }

  Future<void> addToCart(CartItem item) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not authenticated");
    }

    // Check for existing item with same productId, color, and size
    final existingItem = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .where('productId', isEqualTo: item.productId)
        .where('color', isEqualTo: item.color)
        .where('size', isEqualTo: item.size)
        .limit(1)
        .get();

    if (existingItem.docs.isNotEmpty) {
      final doc = existingItem.docs.first;
      final currentQuantity = doc.data()['quantity'] as int;
      await doc.reference.update({
        'quantity': currentQuantity + item.quantity,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .add(item.toMap());
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not authenticated");
    }
    if (newQuantity <= 0) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(itemId)
          .delete();
    } else {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(itemId)
          .update({
        'quantity': newQuantity,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> removeItem(String itemId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not authenticated");
    }
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(itemId)
        .delete();
  }

  Future<void> toggleSelectAll(bool selectAll) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not authenticated");
    }
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();
    final batch = _firestore.batch();
    if (selectAll) {
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'quantity': 1});
      }
    } else {
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
    }
    await batch.commit();
  }

  double calculateTotalPrice(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  int calculateTotalItems(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<void> checkout(List<CartItem> items) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not authenticated");
    }
    if (items.isEmpty) return;

    final batch = _firestore.batch();
    final ordersRef = _firestore.collection('orders').doc();

    batch.set(ordersRef, {
      'userId': userId,
      'date': FieldValue.serverTimestamp(),
      'items': items.map((item) => item.toMap()).toList(),
      'total': calculateTotalPrice(items),
      'status': 'pending',
    });

    for (var item in items) {
      batch.delete(_firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(item.id));
    }

    await batch.commit();
  }
}