import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils.dart' as utils;


class EditProductLogic {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TextEditingController descriptionController;
  final TextEditingController colorController = TextEditingController();
  List<String> selectedColors;
  final List<String> availableColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow', 'Purple', 'Orange', 'Pink'];
  File? imageFile;

  EditProductLogic({
    required String initialName,
    required String initialPrice,
    required String initialQuantity,
    required String initialDescription,
    required List<String> initialColors,
  })  : nameController = TextEditingController(text: initialName),
        priceController = TextEditingController(text: initialPrice),
        quantityController = TextEditingController(text: initialQuantity),
        descriptionController = TextEditingController(text: initialDescription),
        selectedColors = initialColors;

  String? validateName(String? value) {
    return value == null || value.isEmpty ? 'Please enter a product name' : null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a price';
    if (double.tryParse(value) == null) return 'Please enter a valid number';
    if (double.parse(value) <= 0) return 'Price must be greater than 0';
    return null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a quantity';
    if (int.tryParse(value) == null) return 'Please enter a valid whole number';
    if (int.parse(value) < 0) return 'Quantity cannot be negative';
    return null;
  }

  void addColor() {
    String color = colorController.text.trim();
    if (color.isNotEmpty && !selectedColors.any((c) => c.toLowerCase() == color.toLowerCase())) {
      selectedColors.removeWhere((c) => c.toLowerCase() == color.toLowerCase());
      selectedColors.add(color);
      colorController.clear();
    }
  }

  void toggleColor(String color, bool selected) {
    if (selected) {
      selectedColors.removeWhere((c) => c.toLowerCase() == color.toLowerCase());
      selectedColors.add(color);
    } else {
      selectedColors.removeWhere((c) => c.toLowerCase() == color.toLowerCase());
    }
  }

  void removeColor(String color) {
    selectedColors.remove(color);
  }

  Future<void> pickImage() async {
    imageFile = await utils.pickImage();
  }

  void removeImage() {
    imageFile = null;
  }

  Map<String, dynamic> getUpdatedProduct() {
    return {
      'name': nameController.text,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'quantity': int.tryParse(quantityController.text) ?? 0,
      'description': descriptionController.text,
      'colors': selectedColors,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    colorController.dispose();
  }
}