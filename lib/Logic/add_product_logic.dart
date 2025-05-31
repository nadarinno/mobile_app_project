import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductLogic {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController colorController = TextEditingController();

  List<String> selectedColors = [];
  List<String> availableColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow', 'Purple', 'Orange', 'Pink'];
  List<File> imageFiles = [];

  String? validateName(String? value) {
    return value == null || value.isEmpty ? 'Enter product name' : null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Enter price';
    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) return 'Enter a valid price > 0';
    return null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) return 'Enter quantity';
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0) return 'Enter valid quantity';
    return null;
  }

  void addColor() {
    final color = colorController.text.trim();
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
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFiles.add(File(pickedFile.path));
    }
  }

  void removeImage(int index) {
    imageFiles.removeAt(index);
  }

  void resetForm(GlobalKey<FormState> formKey) {
    nameController.clear();
    priceController.clear();
    quantityController.clear();
    descriptionController.clear();
    colorController.clear();
    selectedColors.clear();
    imageFiles.clear();
    formKey.currentState?.reset();
  }

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    colorController.dispose();
  }
}