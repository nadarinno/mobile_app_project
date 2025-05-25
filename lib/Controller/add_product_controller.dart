import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_project/Logic/add_product_logic.dart';

class AddProductController {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AddProductController(this._firestore, this._storage);

  Future<List<String>> uploadImages(List<File> images) async {
    try {
      List<String> imageUrls = [];
      for (var image in images) {
        final fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}_${image.hashCode}.jpg';
        final ref = _storage.ref().child(fileName);
        final uploadTask = await ref.putFile(image);
        final url = await uploadTask.ref.getDownloadURL();
        imageUrls.add(url);
      }
      return imageUrls;
    } catch (e) {
      throw Exception("Failed to upload images: $e");
    }
  }

  Future<void> saveProduct(
      BuildContext context, GlobalKey<FormState> formKey, VoidCallback updateTotals, AddProductLogic logic) async {
    if (!formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }

    try {
      print("Starting product save process...");

      final name = logic.nameController.text.trim();
      final price = double.tryParse(logic.priceController.text.trim()) ?? 0.0;
      final quantity = int.tryParse(logic.quantityController.text.trim()) ?? 0;
      final description = logic.descriptionController.text.trim();

      print("Validating inputs...");
      if (name.isEmpty) throw Exception("Product name cannot be empty");
      if (price <= 0) throw Exception("Price must be greater than 0");
      if (quantity < 0) throw Exception("Quantity cannot be negative");

      List<String> imageUrls = [];
      if (logic.imageFiles.isNotEmpty) {
        print("Uploading images...");
        try {
          imageUrls = await uploadImages(logic.imageFiles);
          print("Images uploaded successfully: $imageUrls");
        } catch (e) {
          print("Image upload failed: $e");
          throw Exception("Image upload failed: $e");
        }
      } else {
        print("No images selected");
      }

      final product = {
        'name': name,
        'price': price,
        'quantity': quantity,
        'description': description,
        'images': imageUrls,
        'colors': logic.selectedColors,
        'createdAt': FieldValue.serverTimestamp(),
      };

      print("Saving to Firestore...");
      final docRef = await _firestore.collection('products').add(product);
      print("✅ Product saved with ID: ${docRef.id}");
      print(product);
      print(docRef);
      updateTotals();

      logic.resetForm(formKey);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print("Error saving product: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to add product: ${e.toString()}"),
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