import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project/Logic/cart_item_model.dart';

class CheckoutModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(List<CartItem> items, double total) async {
    if (items.isEmpty) return;

    final batch = _firestore.batch();
    final ordersRef = _firestore.collection('orders').doc();

    batch.set(ordersRef, {
      'date': DateTime.now(),
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
    });

    for (var item in items) {
      batch.delete(_firestore.collection('cart').doc(item.id));
    }

    await batch.commit();
  }
}