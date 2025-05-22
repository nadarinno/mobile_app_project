import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_for_seller.dart';

Future<void> deleteProduct(BuildContext context, String docId, VoidCallback updateTotals) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

void confirmDelete(BuildContext context, String docId, VoidCallback updateTotals) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirm Delete'),
      content: Text('Are you sure you want to delete this product?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            deleteProduct(context, docId, updateTotals);
            Navigator.of(context).pop();
          },
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}