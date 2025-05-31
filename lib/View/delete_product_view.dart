import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/delete_product_logic.dart';

class DeleteProductView {
  static Future<void> showConfirmDialog(
    BuildContext context,
    String docId,
    VoidCallback updateTotals,
    DeleteProductLogic logic,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this product?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await logic.deleteProduct(
                      dialogContext,
                      docId,
                      updateTotals,
                    );
                  } catch (e) {
                    print("Error in dialog: $e");
                  } finally {
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
