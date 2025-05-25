// logic/product_card_logic.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../logic/product_logic.dart';
class ProductLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Product>> productsStream({
    String? category,
    required String searchQuery,
  }) {
    Query collection = _firestore.collection('products');

    if (category != null && category.isNotEmpty) {
      collection = collection.where('category', isEqualTo: category);
    }

    if (searchQuery.isNotEmpty) {
      collection = collection
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    return collection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Product.fromMap(data);
    })
        .toList());
  }

  Stream<bool> isSaved(String productId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(false); // Fallback for unauthenticated users
    }
    final String userId = user.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<bool> saveItem(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(productId)
          .set({});
      return true;
    } catch (e) {
      print('❌ Failed to save item: $e');
      return false;
    }
  }

  Future<bool> deleteSavedItem(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(productId)
          .delete();
      return true;
    } catch (e) {
      print('❌ Failed to delete saved item: $e');
      return false;
    }
  }
}