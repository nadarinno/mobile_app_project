import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Logic/edit_product_logic.dart';
import '../utils.dart' as utils;

class EditProductController {
  final FirebaseFirestore _firestore;

  EditProductController(this._firestore);

  Future<void> saveProduct(
      BuildContext context, String docId, EditProductLogic logic, VoidCallback updateTotals, VoidCallback onSuccess) async {
    if (!logic.formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }

    try {
      print("Attempting to update product ID: $docId");
      final updatedProduct = logic.getUpdatedProduct();

      // Validate required fields
      if (updatedProduct['name'] == null || updatedProduct['name'].isEmpty) {
        throw Exception("Product name cannot be empty");
      }
      if (updatedProduct['price'] == null || updatedProduct['price'] <= 0) {
        throw Exception("Price must be greater than 0");
      }
      if (updatedProduct['quantity'] == null || updatedProduct['quantity'] < 0) {
        throw Exception("Quantity cannot be negative");
      }

      if (logic.imageFile != null) {
        print("Uploading image...");
        final imageUrl = await utils.uploadImage(logic.imageFile!);
        updatedProduct['image'] = imageUrl;
        print("Image uploaded: $imageUrl");
      }

      await _firestore.collection('products').doc(docId).update(updatedProduct);
      print("Product updated successfully");
      updateTotals();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully')),
      );
      onSuccess();
    } catch (e) {
      print("Error updating product: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to update product: $e"),
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