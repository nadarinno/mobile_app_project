import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeleteProductController {
  final FirebaseFirestore _firestore;

  DeleteProductController(this._firestore);

  Future<void> deleteProduct(
    BuildContext context,
    String? docId,
    VoidCallback updateTotals,
  ) async {
    if (docId == null || docId.isEmpty) {
      print("Error: Invalid or empty docId provided");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid product ID')));
      }
      return;
    }

    try {
      print("Attempting to delete product ID: $docId");
      DocumentReference docRef = _firestore.collection('products').doc(docId);

      // Check if document exists
      DocumentSnapshot docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print("Error: Product with ID $docId does not exist");
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Product not found')));
        }
        return;
      }

      // Check sellerId
      final data = docSnapshot.data() as Map<String, dynamic>?;
      final sellerId = data?['sellerId'] as String?;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      print("Product sellerId: $sellerId, Current user ID: $currentUserId");
      if (sellerId == null || sellerId != currentUserId) {
        print(
          "Error: User not authorized to delete product (sellerId mismatch)",
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are not authorized to delete this product'),
            ),
          );
        }
        return;
      }

      // Attempt deletion
      await docRef.delete();
      print("Product deleted successfully");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
        updateTotals();
      }
    } catch (e) {
      print("Error deleting product: $e");
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Error"),
                content: Text("Failed to delete product: $e"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    }
  }
}
