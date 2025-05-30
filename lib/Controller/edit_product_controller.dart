import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Logic/edit_product_logic.dart';

class EditProductController {
  final FirebaseFirestore firestore;

  EditProductController(this.firestore);

  Future<void> saveProduct(
    BuildContext context,
    String docId,
    EditProductLogic logic,
    VoidCallback updateTotals,
    VoidCallback onSuccess,
  ) async {
    if (logic.formKey.currentState!.validate()) {
      try {
        // Placeholder: Implement image upload logic (e.g., using firebase_storage)
        // List<String> imageUrls = [];
        // for (var file in logic.imageFiles) {
        //   // Upload to Firebase Storage and get URL
        // }
        // imageUrls.addAll(logic.existingImages);

        await firestore.collection('products').doc(docId).update({
          'name': logic.nameController.text,
          'price': double.parse(logic.priceController.text),
          'quantity': int.parse(logic.quantityController.text),
          'description': logic.descriptionController.text,
          'colors': logic.selectedColors,
          // 'images': imageUrls,
        });

        updateTotals();
        onSuccess();
      } catch (e) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(
                  "Error",
                  style: TextStyle(color: Color(0xFF561C24)),
                ),
                backgroundColor: Color(0xFFF5F3ED),
                content: Text(
                  "Failed to save product: $e",
                  style: TextStyle(color: Color(0xFF561C24)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "OK",
                      style: TextStyle(color: Color(0xFF561C24)),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFD0B8A8),
                    ),
                  ),
                ],
              ),
        );
      }
    }
  }
}
