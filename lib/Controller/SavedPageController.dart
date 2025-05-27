import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedPageController {
  final User? user = FirebaseAuth.instance.currentUser;

  CollectionReference get savedItemsCollection =>
      FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('savedItems');

  bool get isAuthenticated => user != null;

  Stream<QuerySnapshot> get savedItemsStream => savedItemsCollection.snapshots();

  Future<void> saveItem({
    required String productId,
    required String productName,
    required double productPrice,
    required String imagePath,
    required BuildContext context,
  }) async {
    try {
      if (!isAuthenticated) {
        Navigator.pushNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to save items'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await savedItemsCollection.doc(productId).set({
        'productId': productId,
        'productName': productName,
        'productPrice': productPrice,
        'imagePath': imagePath,
        'savedAt': FieldValue.serverTimestamp(),
      });

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
          content: Text('Error saving item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  AnimationController initAnimationController(String productId, TickerProvider vsync, {int delay = 0}) {
    final controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );

    Future.delayed(Duration(milliseconds: delay), () {
      controller.forward();
    });

    return controller;
  }


  Future<void> deleteSavedItem(String productId, AnimationController controller, BuildContext context) async {
    print('Deleting item - User UID: ${user?.uid}, Product ID: $productId');
    try {
      if (!isAuthenticated) {
        Navigator.pushNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to manage saved items'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final docRef = savedItemsCollection.doc(productId);
      final doc = await docRef.get();
      if (doc.exists) {
        await controller.reverse();
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


  void viewProduct(String productName, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing $productName details'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: const Color(0xFF561C24),
      ),
    );
  }
}