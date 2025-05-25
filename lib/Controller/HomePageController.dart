import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePageController {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference productsCollection =
  FirebaseFirestore.instance.collection('products');

  // Reference to the user's savedItems subcollection
  CollectionReference get savedItemsCollection =>
      FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('savedItems');

  // Save item to savedItems subcollection
  Future<void> saveItem(String productId, BuildContext context) async {
    print('Saving item - User UID: ${user?.uid}');
    print('Saving item - Product ID: $productId');
    try {
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Fetch product data
      final productDoc = await productsCollection.doc(productId).get();
      if (!productDoc.exists) {
        throw Exception('Product not found: $productId');
      }
      final productData = productDoc.data() as Map<String, dynamic>;
      print('Product data: $productData');

      // Validate price
      final price = productData['price'];
      if (price != null && price is! num) {
        throw Exception('Invalid price format: $price');
      }

      await savedItemsCollection.doc(productId).set({
        'productId': productId,
        'name': productData['name'] ?? 'Unnamed Item',
        'price': price ?? 0.0,
        'image': productData['image'] ?? 'assets/images/cozyshoplogo.png',
        'savedAt': FieldValue.serverTimestamp(),
      });
      print('Successfully saved item: $productId');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete item from savedItems subcollection
  Future<void> deleteSavedItem(String productId, BuildContext context) async {
    print('Deleting item - User UID: ${user?.uid}');
    print('Deleting item - Product ID: $productId');
    try {
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final docRef = savedItemsCollection.doc(productId);
      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
        print('Successfully deleted item: $productId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item removed from saved items'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Item not found in savedItems: $productId');
      }
    } catch (e) {
      print('Error deleting item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Check if a product is saved
  Stream<bool> isSaved(String productId) {
    return savedItemsCollection.doc(productId).snapshots().map((doc) => doc.exists);
  }

  // Check if user is authenticated
  bool get isAuthenticated => user != null;

  // Get products stream
  Stream<QuerySnapshot> get productsStream => productsCollection.snapshots();
}