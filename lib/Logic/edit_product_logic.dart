import 'dart:io';
import 'package:flutter/material.dart';

class EditProductLogic {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TextEditingController descriptionController;
  final TextEditingController colorController;
  final List<String> selectedColors;
  final List<String> availableColors;
  List<File> imageFiles;
  List<String> existingImages;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  EditProductLogic({
    required String initialName,
    required String initialPrice,
    required String initialQuantity,
    required String initialDescription,
    required List<String> initialColors,
  }) : nameController = TextEditingController(text: initialName),
       priceController = TextEditingController(text: initialPrice),
       quantityController = TextEditingController(text: initialQuantity),
       descriptionController = TextEditingController(text: initialDescription),
       colorController = TextEditingController(),
       selectedColors = List.from(initialColors),
       availableColors = [
         'Red',
         'Blue',
         'Green',
         'Yellow',
         'Purple',
         'Orange',
         'Pink',
         'Black',
         'White',
       ],
       imageFiles = [],
       existingImages = [];

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a product name';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a quantity';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity < 0) {
      return 'Please enter a valid quantity';
    }
    return null;
  }

  void addColor() {
    final color = colorController.text.trim();
    if (color.isNotEmpty &&
        !selectedColors.any((c) => c.toLowerCase() == color.toLowerCase())) {
      selectedColors.add(color);
      colorController.clear();
    }
  }

  void removeColor(String color) {
    selectedColors.remove(color);
  }

  void toggleColor(String color, bool selected) {
    if (selected) {
      if (!selectedColors.any((c) => c.toLowerCase() == color.toLowerCase())) {
        selectedColors.add(color);
      }
    } else {
      selectedColors.removeWhere((c) => c.toLowerCase() == color.toLowerCase());
    }
  }

  Future<void> pickImage() async {
    // Placeholder: Implement image picking logic (e.g., using image_picker package)
    // For example:
    // final picker = ImagePicker();
    // final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    // if (pickedFile != null) {
    //   imageFiles.add(File(pickedFile.path));
    // }
  }

  void removeImage(int index) {
    imageFiles.removeAt(index);
  }

  void removeExistingImage(int index) {
    existingImages.removeAt(index);
  }

  void setExistingImages(List<String> images) {
    existingImages = List.from(images);
  }

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    colorController.dispose();
  }
}
