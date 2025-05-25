import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/delete_product_logic.dart';

class DeleteProductView {
  static void showConfirmDialog(
      BuildContext context, String docId, VoidCallback updateTotals, DeleteProductLogic logic) {
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
              logic.deleteProduct(context, docId, updateTotals);
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}