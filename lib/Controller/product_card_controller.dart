import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;


  Stream<bool> isSaved(String productId) {
    if (_uid == null) {
      return Stream.value(false);
    }
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('savedItems')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }


  Future<void> toggleSaved(
      String productId,
      bool isCurrentlySaved,
      BuildContext context, {
        String? name,
        double? price,
        String? imageUrl,
      }) async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    final docRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('savedItems')
        .doc(productId);

    try {
      if (isCurrentlySaved) {

        await docRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      } else {

        await docRef.set({
          'productId': productId,
          'name': name ?? '',
          'price': price ?? 0,
          'image': imageUrl ?? '',
          'savedAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
