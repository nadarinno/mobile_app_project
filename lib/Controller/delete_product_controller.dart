import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteProductController {
  final FirebaseFirestore _firestore;

  DeleteProductController(this._firestore);

  Future<void> deleteProduct(BuildContext context, String docId, VoidCallback updateTotals) async {
    try {
      print("Attempting to delete product ID: $docId");
      await _firestore.collection('products').doc(docId).delete();
      print("Product deleted successfully");
      updateTotals();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      print("Error deleting product: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to delete product: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}